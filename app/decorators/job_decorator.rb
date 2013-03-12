class JobDecorator < Draper::Base

  include ActionView::Helpers::NumberHelper

  decorates :job

  # Accessing Helpers
  #   You can access any helper via a proxy
  #
  #   Normal Usage: helpers.number_to_currency(2)
  #   Abbreviated : h.number_to_currency(2)
  #
  #   Or, optionally enable "lazy helpers" by including this module:
  #     include Draper::LazyHelpers
  #   Then use the helpers with no proxy:
  #     number_to_currency(2)

  # Defining an Interface
  #   Control access to the wrapped subject's methods using one of the following:
  #
  #   To allow only the listed methods (whitelist):
  #     allows :method1, :method2
  #
  #   To allow everything except the listed methods (blacklist):
  #     denies :method1, :method2

  # Presentation Methods
  #   Define your own instance methods, even overriding accessors
  #   generated by ActiveRecord:
  #
  #   def created_at
  #     h.content_tag :span, attributes["created_at"].strftime("%a %m/%d/%y"),
  #                   :class => 'timestamp'
  #   end
  #

  def thumbnail_url
    company.image.url(:thumbnail)
  end

  def company_name
    company.name
  end

  def formatted_salary_low
    number_to_currency(salary_low * 1000, precision: 0)
  end

  def formatted_salary_high
    number_to_currency(salary_high * 1000, precision: 0)
  end

  def city_name
    city.name
  end

  def posted_date
    created_at.to_date.to_s(:long)
  end

  def expires_date
    expires_on.to_date.to_s(:long)
  end

  def clickthrough
    if email.present?
      "mailto:#{email}"
    elsif link.present?
      link
    else
      ''
    end
  end

end