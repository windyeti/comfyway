require 'test_helper'

class InsalesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get insales_index_url
    assert_response :success
  end

end
