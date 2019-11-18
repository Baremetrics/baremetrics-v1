class User < ActiveRecord::Base
  authenticates_with_sorcery!

  belongs_to :account

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :first_name, :last_name, :account_id, :admin, :reports_daily, :reports_weekly, :reports_monthly
  attr_accessor :name

  validates_presence_of :name, :on => :create
  validates :email,
    :presence => {:message => "can't be blank"},
    :allow_blank => true,
    :uniqueness => { :case_sensitive => false },
    :format => {:with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i}

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_length_of :password, :minimum => 6, :message => "must be at least 6 characters long", :if => :password, :on => :create

  def name
    [first_name, last_name].join(' ') unless first_name.blank?
  end

  def name=(name)
    split = name.split(' ', 2)
    self.first_name = split.first
    self.last_name = split.last
  end

  def self.generate_temporary_password(size = 12)
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K L M N P Q R T V W X Y Z a b c d e f g h i j k l m n o p q r s t u v w x y z}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end
end
