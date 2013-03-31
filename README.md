# Reindeer - Moose sugar in ruby

Takes Ruby's existing OO features and extends them with some sugar
borrowed from [Moose](http://p3rl.org/Moose).

# Installation

    gem install reindeer

# Usage

    require 'reindeer'
    class Point < Reindeer
      has :x, is: :rw, is_a: Integer
      has :y, is: :rw, is_a: Integer
    end
    class Point3D < Point
      has :z, is: :rw, is_a: Integer
    end

# Features

These features are supported to a lesser or greater extent:

## Construction

The `build` method can be used where one may have previously used
`initialize`. It is called after all attributes have been setup so,
laziness permitting, the object should be in a known state.

Another facet of this feature is that each `build` method is called in
the inheritance chain from most-derived to least.

## Attributes

Declared with the alternative syntax `has` they provide
additional functionality while still remaining pure Ruby attributes
under the hood.

Their values can be passed to the `new` constructor in a hash where
the symbolic keys map to attributes of the same. When a value is
specified for a `lazy` attribute it obviates the laziness.

The following options are supported:

### is (aka accessors)

Available in 3 flavours:

* `:ro`
* `:rw`
* `:bare`

The first two provide accessors like `attr_reader` and
`attr_{reader,writer}` combined. The third explicitly provides no
accessors which can be useful when delegators are specified.

The default behaviour is `:ro`.

### required (aka required attributes)

If specified with a `true` value then the attribute must be specified
at build time. Additionally `required` attributes can't be `lazy`
attributes.

### default (aka default attribute values)

Can take either a value or something callable (e.g a `Proc`). If a
value is provided it is `clone`d and if a callable is provided it is
`call`ed without any arguments. The resulting value is used to
populate the attribute if it wasn't provided to the constructor at
object construction time or on first access if the attribute is
`lazy`.

### lazy (aka lazily evaluated)

Expects a `Boolean` and if `true` then the attribute's value isn't
generated until it is accessed (if at all). If specified the attribute
*must* also either have a `builder` or `default` specified otherwise an
`Reindeer::Meta::Attribute::AttributeError` is thrown.

### lazy_build

If passed `true` makes the attribute `lazy` and expects a private
`builder` method of the same name as the attribute, but prefixed with
`build_`, to be defined e.g given `has :foo, lazy_build: true` the
private instance method `build_foo` should be defined. In addition
clearer and predicate methods will be installed with the prefixes
`clear_` and `has_` respectively e.g `clear_foo!` and `has_foo?`.

### handles (aka delegation methods)

Given an array of symbols each one adds an instance method that
delegates to a method of the same name on the attribute value.

### type_of (aka type constraints)

Expects a class that composes the `Reindeer::Role::TypeConstraint`
role. At the point a value is about set against an attribute it is
checked against the type constraint, if valid then the value is set if
not then an `Reindeer::TypeConstraint::Invalid` exception is raised.

## Roles

These are implemented in terms of `Module` and act to serve a similar
purpose. What they provide in addition to `Module` are required
methods and the attributes described above.

To compose a role in a Reindeer class two expressions are required,
`with` and `meta.compose!`, the former behaves like `include` and the
latter brings in the role attributes and asserts the existence of any
required methods e.g

    module Breakable
      include Reindeer::Role
      has :is_broken, default: -> { false }
      requires :fix!
    end
    
    class Egg < Reindeer
      with Breakable
      
      def fix!
        throw :no_dice if is_broken
      end
      
      meta.compose!
    end

The `.does?` method can be used to inspect which roles have been
consumed e.g `Egg.does?(Breakable) == true`.

For further elaboration on the subject of roles see the
[Moose::Manual::Roles](https://metacpan.org/module/Moose::Manual::Roles)
documentation.

## Class constraints and Type constraints

Given that Ruby has a well established class system one need only
assert an attribute is of a given (existing) class a Reindeer will go
to the trouble of asserting that when the attribute value is set e.g

    class AccountSqlTable < Reindeer
      has :id,     is_a: Fixnum
      has :owner,  is_a: String
      has :amount, is_a: Float
      # ...
    end

However if you need a specific type of class (e.g strings of a certain
length) then a custom type constraint is needed. These can be defined
simply by composing the `Reindeer::Role::TypeConstraint` and
implementing a `verify` method e.g

    class Varchar255 < Reindeer
      with Reindeer::Role::TypeConstraint
      def verify(v)
        v.length <= 255
      end
      meta.compose!
    end

    class AccountSqlTable # continued from above
      has :summary, type_of: Varchar255
    end

*NB* The distinction between class and type constraints seems apt at this
point but is by no means set in stone. Hopefully the passage of time
shall enlighten us on the matter.

# Contributing

Pull requests welcome.

# Author

Dan Brook `<dan@broquaint.com>`
