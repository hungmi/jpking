require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get guide" do
    get :guide
    assert_response :success
  end

end
