require 'test/unit'
require 'yargi'

module Yargi

  # Tests all predidate classes
  class PredicateTest < Test::Unit::TestCase

    def test_to_predicate
      assert TruePredicate===Predicate.to_predicate(nil)
      assert TruePredicate===Predicate.to_predicate(true)
      assert FalsePredicate===Predicate.to_predicate(false)
      assert TagPredicate===Predicate.to_predicate(Yargi)
      assert TagPredicate===Predicate.to_predicate(PredicateTest)
      assert LambdaPredicate===(Predicate.to_predicate {|elm| true})
      proc = Proc.new {|elm| true}
      assert LambdaPredicate===Predicate.to_predicate(proc)
      assert AndPredicate === (Predicate.to_predicate(Yargi) {|elm| true})
    end

    def test_tag_predicate
      p = TagPredicate.new(Test::Unit::TestCase)
      assert p===self
      assert_equal false, p===p
    end

    def test_lambda_predicate
      p = LambdaPredicate.new {|elm| Test::Unit::TestCase===elm}
      assert p===self
      assert_equal false, p===p
    end

    def test_not_predicate
      p = TagPredicate.new(Test::Unit::TestCase)
      p = NotPredicate.new(p)
      assert_equal false, p===self
      assert_equal true, p===p
    end

    def test_and_predicate
      assert_equal true, Object===self
      p1 = TagPredicate.new(Object)
      p2 = LambdaPredicate.new {|elm| elm.respond_to?(:test_and_predicate)}
      anded = AndPredicate.new(p1, p2)
      assert_equal true, anded===self
      assert_equal false, anded==="hello"
    end

    def test_or_predicate
      p1 = LambdaPredicate.new {|elm| elm.respond_to?(:upcase)}
      p2 = LambdaPredicate.new {|elm| elm.respond_to?(:test_and_predicate)}
      ored = OrPredicate.new(p1, p2)
      assert_equal true, ored===self
      assert_equal true, ored==="hello"
      assert_equal false, ored===12
    end

    def test_not_accepts_modules
      p = NotPredicate.new(Test::Unit::TestCase)
      assert_equal false, p===self
      assert_equal true, p==="hello"
    end

    def test_ruby_shortcuts
      all = Yargi::ALL
      none = Yargi::NONE
      p = all & Test::Unit::TestCase
      assert_equal true, p===self
      assert_equal false, p==="hello"
      p = p.not()
      assert_equal false, p===self
      assert_equal true, p==="hello"

      respond = LambdaPredicate.new {|elm| elm.respond_to?(:test_and_predicate)}
      assert_equal true, respond===self
      p = all & Test::Unit::TestCase & respond
      assert_equal true, p===self

      ored = none|all
      assert_equal true, ored===self

      ored = none|respond|String
      assert_equal true, ored===self
      assert_equal true, ored==="hello"
      assert_equal false, ored===12
    end

  end # class PredicateTest

end