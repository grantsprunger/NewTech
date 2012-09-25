class Office < ActiveRecord::Base
  attr_accessible :address1, :city_id, :zip_code, :latitude, :longitude

  belongs_to :company

  belongs_to :city

  has_many :tags, :through => :company

  delegate :id, :name, :permalink, :homepage_url, :description, :overview, :hiring,
           :number_of_employees, :founded_year, :email_address, :phone_number, :image,
           :to => :company, :prefix => true

  validates_presence_of :address1, :city_id, :zip_code

  validates_numericality_of :zip_code

  scope :with_companies_founded_from,
        lambda {|year|
          joins(:company).merge(Company.founded_from(year))
        }

  scope :with_companies_founded_to,
        lambda {|year|
          joins(:company).merge(Company.founded_to(year))
        }

  scope :with_company_tagged_as,
        lambda {|tag_code|
          joins(:tags).merge(Company.tagged_as(tag_code))
        }

  scope :located_in_county,
        lambda {|county_id|
          joins(:city).merge(City.with_county_id(county_id))
        }

  scope :with_company_are_hiring,
        joins(:company).merge(Company.are_hiring)


  scope :with_company_employee_type,
        lambda {|employee_id|
          joins(:company).merge(Company.employee_type(employee_id))
        }

  scope :with_company_investment_type,
        lambda {|investment_id|
          joins(:company).merge(Company.investment_type(investment_id))
        }


  def full_address
    "#{address1}, #{zip_code}, #{city.name}"
  end
end
