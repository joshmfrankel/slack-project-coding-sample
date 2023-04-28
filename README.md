# Slack bot challenge

web: https://slack-bot-challenge.onrender.com/

## Technology & Patterns

* Ruby on Rails
* [Tailwind CSS](https://tailwindcss.com/) inspired css
* Service pattern with [dry-monads](https://dry-rb.org/gems/dry-monads/1.3/do-notation/)
* Presenter pattern with [SimpleDelegator](https://ruby-doc.org/stdlib-2.5.1/libdoc/delegate/rdoc/SimpleDelegator.html)
* Transformer pattern for unpacking JSON payloads

## Dependencies

* dotenv-rails - For EnvVar local configuration
* slack-ruby-client - For interacting with Slack API
* dry-monads - For implementing Railway Oriented Programming for Service objects
* pagy - For blazing fast Pagination
* webmock - To ensure all external requests in the test suite are stubbed
* should-context - For useful Minitest DSL syntax
* mocha - For mocking objects in Minitest
* pry - For general debugging purposes

## Limitations

* There is no User authentication. In a real application this would be important to segment data.
* There are no business logic authorization checks. I would implement policies with the usage of [Pundit](https://github.com/varvet/pundit). The policy pattern would ensure we can answer the following questions: "Can this user perform this action?" and "Can this user access this resource?"
* Slack access tokens are not rotated and are therefore never expire. In production,
they should be rotated. https://api.slack.com/authentication/rotation
