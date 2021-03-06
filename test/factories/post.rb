FactoryGirl.define do
  factory :post do
    title "title"
    body "body"
    thumbnail { Rails.root.join("test/fixtures/images/thumbnail.jpg").open }
    published_at { DateTime.parse("2016-01-01") }

    transient do
      categories []
    end

    after :build do |post, evaluator|
      evaluator.categories.each do |category|
        post.categorizations.build(attributes_for(:categorization, :whatever, category: category))
      end
    end

    after(:create, &:reload) # To refresh `post.categories`

    trait :whatever do
      site
      before :create do |post, _evaluator|
        post.categorizations.build(attributes_for(:categorization, :whatever, site: post.site))
      end
    end

    trait :unpublished do
      published_at nil
    end

    trait :with_pages do
      body <<~BODY
        # title

        body

        <!--nextpage-->

        ## title 2

        hello

        <!--nextpage-->

        ## title 3

        world
      BODY
    end

    trait :with_credit do
      before :create do |post, _evaluator|
        post.credits << build(:credit, :whatever, site: post.site)
      end
    end
  end
end
