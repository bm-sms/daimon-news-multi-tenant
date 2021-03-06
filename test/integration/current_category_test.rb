require "test_helper"
require "active_support/testing/time_helpers"

class CurrentCategoryTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    travel_to Time.zone.parse("2000-01-01 00:00:00")

    @site = create(:site, name: "daimon-news", fqdn: "example.com")

    description = <<~EOS
      [Ruby](https://www.ruby-lang.org/) is a programming language.
    EOS
    category = create(:category, site: @site, name: "Ruby", slug: "ruby", description: description)
    body = <<~EOS
      Ruby x.x.x released just now!
    EOS
    create(:post,
           site: @site,
           title: "Ruby x.x.x Released",
           body: body,
           thumbnail: Rails.root.join("test/fixtures/images/thumbnail.jpg").open,
           published_at: Time.zone.parse("2000/01/01 00:00"),
           categorizations_attributes: [{category: category, order: 1}])
    switch_domain(@site.fqdn)
  end

  teardown do
    travel_back
  end

  test "mark current category" do
    visit("/category/ruby")

    assert_equal("Ruby | #{@site.name}", title)

    within(".menu__items") do
      assert_equal("Ruby", find(".menu__item[data-menu-item-state=current]").text)
    end

    within(".main-pane") do
      click_on "Ruby x.x.x Released"
    end

    within(".menu__items") do
      assert_equal("Ruby", find(".menu__item[data-menu-item-state=current]").text)
    end
  end

  test "render description as Markdown" do
    visit("/category/ruby")

    assert_equal("https://www.ruby-lang.org/", find(".category-description a")[:href])
  end

  test "render meta description" do
    visit("/category/ruby")
    assert_equal("Ruby is a programming language.", find("meta[name=description]", visible: false)["content"])
  end

  sub_test_case "render meta description (in case category description is blank)" do
    setup do
      @site.update!(tagline: "This is awesome sites!")
      @category = create(:category, site: @site, name: "Python", slug: "python", description: "")
      @post = create(:post, :with_pages, site: @site, categorizations_attributes: [{category: @category, order: 1}])
    end

    test "test execution" do
      visit("/category/python")
      assert_equal(@site.tagline, find("meta[name=description]", visible: false)["content"])
    end
  end
end
