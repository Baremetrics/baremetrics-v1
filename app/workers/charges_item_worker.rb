class ChargesItemWorker
  include Sidekiq::Worker

  def perform(account_id, date)
    date = date.to_date
    account = Account.find(account_id)
    api_key = account.stripe_access_token

    # Destroy previous bits so we don't get double entries -- Needed if worker restart mid-process
    Stat.where(account_id: account.id, method_name: 'charge.gross_sales', occurred_on: date).destroy_all
    Stat.where(account_id: account.id, method_name: 'charge.refunds', occurred_on: date).destroy_all
    Stat.where(account_id: account.id, method_name: 'balance.fees', occurred_on: date).destroy_all
    Stat.where(account_id: account.id, method_name: 'balance.lost_rev', occurred_on: date).destroy_all
    Stat.where(account_id: account.id, method_name: 'accounts.active', occurred_on: date).destroy_all
    Stat.where(account_id: account.id, method_name: 'money.per_day', occurred_on: date).destroy_all

    offset = 0
    data_count = false
    until data_count == 0
      charges = Stripe::Charge.all(
        {count: 100,
        offset: offset,
        expand: [['data.invoice'], ['data.balance_transaction']],
        created: {
          gte: date.beginning_of_day.to_i,
          lte: date.end_of_day.to_i
        }},
        api_key
      )
      offset += 100
      data_count = charges.data.count

      if data_count > 0

        charges.each do |charge|
          amount = charge.amount
          if charge.invoice.present? and charge.paid == true

            invoice = charge.invoice
            date = Time.at(invoice.date).to_datetime.to_date

            charge.invoice.lines.each do |line|
              if line.type == 'subscription'
                invoice_plan_id = line.plan.id

                # Money Per Day
                mpd_amount_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'money.per_day', "money.#{invoice_plan_id}.per_day", date)
                new_mpd_amount_stat_count = mpd_amount_stat.data.to_i + amount
                mpd_amount_stat.update_attributes(data: new_mpd_amount_stat_count)

                # Active Accounts
                active_accounts_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'accounts.active', "accounts.#{invoice_plan_id}.active", date)
                new_active_accounts_stat_amount = active_accounts_stat.data.to_i + 1
                active_accounts_stat.update_attributes(data: new_active_accounts_stat_amount)

                # Sales
                gross_sales_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'charge.gross_sales', "charge.#{invoice_plan_id}.gross_sales", date)
                new_gross_sales_stat_amount = gross_sales_stat.data.to_i + amount
                gross_sales_stat.update_attributes(data: new_gross_sales_stat_amount)

                # Refunds
                if charge.amount_refunded > 0
                  refund_amount = charge.amount_refunded
                  refunds_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'charge.refunds', "charge.#{invoice_plan_id}.refunds", date)
                  new_refunds_stat_amount = refunds_stat.data.to_i + refund_amount
                  refunds_stat.update_attributes(data: new_refunds_stat_amount)
                end

                # Fees
                if charge.balance_transaction.present?
                  fee = charge.balance_transaction.fee
                  fees_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'balance.fees', "balance.#{invoice_plan_id}.fees", date)
                  new_fees_stat_amount = fees_stat.data.to_i + fee
                  fees_stat.update_attributes(data: new_fees_stat_amount)
                end

                # Calculate rev loss for discount
                if invoice.subtotal > invoice.total and invoice.discount.present?
                  lost_rev = invoice.subtotal - invoice.total
                  lost_rev_stat = Stat.find_or_create_by_account_id_and_method_name_and_method_key_and_occurred_on(account.id, 'balance.lost_rev', "balance.#{invoice_plan_id}.lost_rev", date)
                  new_lost_rev_stat_amount = lost_rev_stat.data.to_i + lost_rev
                  lost_rev_stat.update_attributes(data: new_lost_rev_stat_amount)
                end
              end
            end


          end
        end
      end
    end

  end
end