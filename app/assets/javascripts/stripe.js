$('.payment-form').ready(function() {
  $('.payment-form').submit(function() {
    var $form = $(this);

    // Disable the submit button to prevent repeated clicks
    $form.find('button').prop('disabled', true);

    Stripe.createToken($form, stripeResponseHandler);

    // Prevent the form from submitting with the default action
    return false;
  });

  var stripeResponseHandler = function(status, response) {
    var $form = $('.payment-form');

    if (response.error) {
      // Show the errors on the form
      $form.find('.message_placeholder').show();
      $form.find('.message_placeholder').html("<div class='alert-box alert radius'>"+response.error.message+"</div>");
      $form.find('button').prop('disabled', false);
    } else {
      // token contains id, last4, and card type
      var token = response.id;
      // Insert the token into the form so it gets submitted to the server
      $form.append($('<input type="hidden" name="account[stripe_token]" />').val(token));
      // and submit
      $form.get(0).submit();
    }
  };
});