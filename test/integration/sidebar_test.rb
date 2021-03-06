require "test_helper"

class SidebarTest < ActionDispatch::IntegrationTest
  setup do
    setup_groonga_database
    @post = create(:post, :whatever, body: <<~EOS.encode(crlf_newline: true))
      # hi
      contents
    EOS

    switch_domain(@post.site.fqdn)
    @indexer = PostIndexer.new
  end

  teardown do
    teardown_groonga_database
  end

  test "top page does not display recent posts on sidebar" do
    visit "/"

    within ".wrappable__content.promotions" do
      assert(page.has_no_selector?("h2", text: "新着記事"))
    end
  end

  test "pages except top page display recent posts on sidebar" do
    visit "/#{@post.public_id}"

    within ".wrappable__content.promotions" do
      assert(page.has_selector?("h2", text: "新着記事"))
    end

    visit "/category/#{@post.main_category.slug}"

    within ".wrappable__content.promotions" do
      assert(page.has_selector?("h2", text: "新着記事"))
    end
  end

  test "search result page display recent posts on sidebar" do
    visit "/"
    fill_in "query[keywords]", with: "contents"
    click_on "検索"

    within ".wrappable__content.promotions" do
      assert(page.has_selector?("h2", text: "新着記事"))
    end
  end

  sub_test_case "serials" do
    test "serials section is not displayed if no serials" do
      visit "/"

      within ".wrappable__content.promotions" do
        assert(page.has_no_selector?("h2", text: "連載"))
      end
    end

    test "serials section is displayed if any serials are exist" do
      create(:serial, site: @post.site)

      visit "/"

      within ".wrappable__content.promotions" do
        assert(page.has_selector?("h2", text: "連載"))
      end
    end
  end

  sub_test_case "pickup_posts" do
    test "pickup posts section is not displayed if no pickup posts" do
      create(:pickup_post, :whatever, site: create(:site))

      visit "/"

      within ".wrappable__content.promotions" do
        assert(page.has_no_selector?("h2", text: "ピックアップ"))
      end
    end

    test "pickup posts is displayed if any pickup posts are exist" do
      create(:pickup_post, :whatever, site: @post.site)

      visit "/"

      within ".wrappable__content.promotions" do
        assert(page.has_selector?("p", text: @post.title))
        assert(page.has_selector?("h2", text: "ピックアップ"))
      end
    end
  end

end
