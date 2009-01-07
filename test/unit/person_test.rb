require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  fixtures :people, :projects,:institutions, :work_groups, :group_memberships,:users
  
  # Replace this with your real tests.
  def test_work_groups
    p=people(:one)
    assert_equal 2,p.work_groups.size
  end
  
  def test_institutions
    p=people(:one)
    assert_equal 2,p.institutions.size
    
    p=people(:two)
    assert_equal 2,p.work_groups.size
    assert_equal 2,p.projects.size
    assert_equal 1,p.institutions.size
  end
  
  def test_projects
    p=people(:one)
    assert_equal 2,p.projects.size
  end
  
  def test_userless_people
    peeps=Person.userless_people
    assert_not_nil peeps
    assert peeps.size>0,"There should be some userless people"
    assert_nil peeps.find{|p| !p.user.nil?},"There should be no people with a non nil user"    

    p=people(:three)
    assert_not_nil peeps.find{|person| p.id==person.id},"Person :three should be userless and therefore in the list"

    p=people(:one)
    assert_nil peeps.find{|person| p.id==person.id},"Person :one should have a user and not be in the list"
  end

  def test_name
      p=people(:one)
      assert_equal "Quentin Jones", p.name
      p.first_name="Tom"
      assert_equal "Tom Jones", p.name
  end

  def test_capitalization_with_nil_last_name
    p=people(:no_first_name)
    assert_equal " Lastname",p.name
  end

  def test_capitalization_with_nil_first_name
    p=people(:no_last_name)
    assert_equal "Firstname ",p.name
  end


end
