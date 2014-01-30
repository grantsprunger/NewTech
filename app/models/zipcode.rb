class Zipcode < ActiveRecord::Base
  attr_accessible :code, :latitude, :longitude

  has_and_belongs_to_many :counties

  has_many :companies

  has_many :tags, :through => :companies
  
  scope :with_companies_name_like,
        lambda {|name|
          joins(:companies).merge(Company.name_like(name))
        }

  scope :with_companies_founded_from,
        lambda {|year|
          joins(:companies).merge(Company.founded_from(year))
        }

  scope :with_companies_founded_to,
        lambda {|year|
          joins(:companies).merge(Company.founded_to(year))
        }

  scope :with_company_tagged_as,
        lambda {|tag_code|
          joins(:companies).merge(Company.tagged_as(tag_code))
        }

  scope :with_companies_in_county,
        lambda {|county_id|
          joins(:companies).merge(Company.located(county_id))
        }

  scope :with_company_are_hiring,
        joins(:cities).where('cities.jobs_count > 0')

  scope :with_company_employee_type,
        lambda {|employee_id|
          joins(:companies).merge(Company.employee_type(employee_id))
        }

  scope :with_company_investment_type,
        lambda {|investment_id|
          joins(:companies).merge(Company.investment_type(investment_id))
        }

  scope :with_company_category,
        lambda {|category_id|
          joins(:companies).merge(Company.with_category(category_id))
        }

end
