class Company < ActiveRecord::Base
  attr_accessible :name,
                  :offices_attributes,
                  :email_address,
                  :founded_year,
                  :description,
                  :homepage_url,
		  :kickstarter_url,
		  :kickstarter_end_date,
                  :twitter,
                  :facebook,
                  :jobs_url,
                  :image,
                  :investments_type_id,
                  :employees_type_id,
                  :category_id,
                  :presentation_date,
                  :user_id,
                  :enabled,
                  :presented,
                  :address,
                  :city_id,
                  :zip_code,
                  :latitude,
                  :longitude

  belongs_to  :user

  belongs_to  :investments_type

  belongs_to  :employees_type

  belongs_to :city

  belongs_to :county

  belongs_to :category

  has_and_belongs_to_many :tags

  has_many :jobs, dependent: :destroy

  validates_presence_of :address, :city_id, :zip_code, :category_id

  validates_numericality_of :zip_code

  before_save :attach_county

  has_attached_file :image,
                    :styles => {
                        :thumbnail => "160x120>",
                        thumb: "100x100>",
                        icon: "25x25>",
                        regular: "175x175>",
                        small: "35x35>",
                        thumb_large: "75x75>",
                        thumb_small: "55x55>"
                    },
                    :default_url => "http://b.dryicons.com/images/icon_sets/colorful_stickers_icons_set/png/256x256/help.png",
                    :storage => :s3,
                    :s3_protocol => 'https',
                    :s3_permissions => :public_read,
                    :bucket => configatron.s3.bucket,
                    :s3_credentials => {
                        :access_key_id => configatron.s3.credentials.access_key_id,
                        :secret_access_key => configatron.s3.credentials.secret_access_key
                    },
                    :path => "/:class/:id/:style.:extension"


  validates_attachment_size :image, :less_than => 1.megabyte
  validates_attachment_content_type :image, :content_type => /image/

  validates_presence_of :name, :email_address, :founded_year

  validates_numericality_of :founded_year, :less_than_or_equal_to => Time.now.year

  scope :name_like,
        lambda {|name|
          where("companies.name ILIKE ?", "%#{name}%")
        }

  scope :founded_from,
        lambda {|year|
          where("companies.founded_year >= ?", year)
        }

  scope :founded_to,
        lambda {|year|
          where("companies.founded_year <= ?", year)
        }


  scope :tagged_as,
        lambda {|tag_code|
          joins(:tags).where("tags.code = ?", tag_code)
        }

  scope :with_active_kickstarter,
        Company.select("companies.*")
  	       .from("companies")
	       .where('companies.kickstarter_url is not null AND companies.kickstarter_end_date >= ?', DateTime.now)

  scope :are_hiring,
        where('companies.jobs_count > 0')

  scope :employee_type,
        lambda {|employee_id|
          where("companies.employees_type_id = ?", employee_id)
        }

  scope :investment_type,
        lambda {|investment_id|
          where("companies.investments_type_id = ?", investment_id)
        }

  scope :with_category,
        lambda {|category_id|
          where("companies.category_id = ?", category_id)
        }

  scope :located_in_county,
        lambda {|id|
          where("companies.county_id = ?", id)
        }

  def is_hiring?
    (self.jobs_count || 0) > 0
  end

  def number_of_employees
    employees_type.name rescue 0
  end

  def tags_list
    tags.map(&:code).join(", ")
  end

  def self.get_recent_companies(limit=5)
    Company.select("companies.*, cnt.name as county_name").joins("INNER JOIN counties cnt on cnt.id = companies.county_id").order("companies.created_at DESC").first(limit)
  end

  private
  def attach_county
    self.county = city.county unless city.county.nil?
  end

end
