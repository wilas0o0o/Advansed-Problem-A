class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books,dependent: :destroy
  attachment :profile_image, destroy: false
  has_many :favorites,dependent: :destroy
  has_many :book_comments,dependent: :destroy

  has_many :active_relationships,class_name: "Relationship",foreign_key: "follower_id",dependent: :destroy
  has_many :passive_relationships,class_name: "Relationship",foreign_key: "followed_id",dependent: :destroy

  has_many :followings,through: :active_relationships,source: :followed
  has_many :followers,through: :passive_relationships,source: :follower

  validates :name, length: {maximum: 20, minimum: 2}, uniqueness: true
  validates :introduction, length: {maximum: 50}

  def following?(user)
    followings.include?(user)
  end
  
  def follow(user_id)
    active_relationships.create(followed_id: user_id)
  end
  
  def unfollow(user_id)
    active_relationships.find_by(followed_id: user_id).destroy
  end
  
  def self.search_for(content,method)
  	if method == "perfect"
  		User.where(title: content)
  	elsif method == "forward"
  		User.where(title: content + "%")
  	elsif method == "backward"
  		User.where(title: "%" + content)
  	else
  		User.where(title: "%" + content + "%")
  	end
  end
end
