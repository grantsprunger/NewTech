class SkillType < ActiveRecord::Base
  attr_accessible :name

  has_many :recommendations, class_name: "Recommendation"

  has_many :skills_set, class_name: "UsersSkills"
  has_many :users, through: :skills_set

  def user_recommendies(recommendi_id)
    recommendations.where(recommendi_id: recommendi_id)  
  end
end
