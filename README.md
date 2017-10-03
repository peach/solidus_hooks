
Spree Hooks

## Installation

Add to `Gemfile`:
```ruby
gem 'spree_hooks', github: 'spree-contrib/spree_hooks'
```

Run:
```sh
$ bundle && bundle exec rails g spree_hooks:install
```

-----------------

Following are two engines, one to handle events, under the Observer
module and another to perform notifications, under the Hooks module.

In the case of the observer module, the Event model is defined.
to be identified by a name (optional) is associated with a model
(required) and defines a triggers hash. A trigger can indicate
simply that an attribute of a model takes a value, for example

    {"checked": true}

defines a trigger that is thrown when the "checked" attribute takes the
value true. More complex triggers can be defined using a
syntax inspired by MongoDB query selectors, for example

    {"price": {"$ gt": 100}}

defines a trigger that is thrown when the "price" attribute takes a
value greater than `100`. The reason for choosing the syntax of
the query selector of MongoDB is mainly by the prefix $,
which should not be confused with the name of any attribute, since it does not
would be a valid name, and in addition, could be easily converted to a selector
to perform a query the database.

Spree's more complex models, say Order and Product, delegate
several attributes to in other models. For example the price of a
product is stored in the Spree called the "master" variant which is
a reference to a Variant type record and this in turn stores the
price in a reference "default_price" to a record of type Price that
finally has an attribute "amount" with the price.

The event model has been conditioned to be able to create
events easily. For example, if we want to define an event that is
when the price of a product changes, the trigger
would be defined as:

    {"master": {"default_price": {"amount": {"$ changes": true}}}}

Actually this trigger is broken down and a chain of events is created
which dependent it causes to result with the desired effect.

On the other hand, the module Hooks defines at the moment the model WebHook
which can have a name (optional) a token listener (also
optional) and a URL. A web hook can also be associated with one or
various events so that when any of the associated events
is triggered, this causes the hook to perform a POST to the configured URL
sending a JSON content with the following structure:

```
  {
     "hook_id": 'The hook identifier',
     "event_id": 'The event identifier that triggered the hook',
     "token": 'The hook token listener, this can be used in the listener to take one or another action',
     "record_id": 'The record identifier where the event occurred',
     "model": 'The name of the model to which the record belongs'.
  }
```

with this information the listener who has registered the hook can
request by the Spree API the information about the record
involved in the event.

Finally, these two Event models as WebHook, have been integrated
to the Spree API, so that they can be configured remotely. The
access routes for the REST API of Spree are, for example in the
store1 case

    http://localhost:3000/api/v1/events
    http://localhost:3000/api/v1/web_hooks
