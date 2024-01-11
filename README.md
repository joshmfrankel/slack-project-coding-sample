# Slack Project Coding Sample

A sample of my coding style in the format of a Slack bot project. The bot is able to respond to several commands which interact with the application's data. Additionally, the application has a simple paginated front-end that utilzes Turbo Frames from Hotwire.

web: https://slack-bot-challenge.onrender.com/
project: https://github.com/users/joshmfrankel/projects/5/views/1?layout=board

## Technology & Patterns

* Ruby on Rails
* [Tailwind CSS](https://tailwindcss.com/) inspired css
* [Hotwire Turbo Frames](https://github.com/joshmfrankel/slack-project-coding-sample/blob/main/app/views/incidents/index.html.erb)
* [Minitest code coverage](https://github.com/joshmfrankel/slack-project-coding-sample/tree/main/test)
* [Service pattern](https://github.com/joshmfrankel/slack-project-coding-sample/tree/main/app/services) with [dry-monads](https://dry-rb.org/gems/dry-monads/1.3/do-notation/)
* [Presenter pattern](https://github.com/joshmfrankel/slack-project-coding-sample/tree/main/app/presenters) with [SimpleDelegator](https://ruby-doc.org/stdlib-2.5.1/libdoc/delegate/rdoc/SimpleDelegator.html)
* [Transformer pattern](https://github.com/joshmfrankel/slack-project-coding-sample/tree/main/app/transformers/slack) for unpacking JSON payloads
* [Query object pattern](https://github.com/joshmfrankel/slack-project-coding-sample/tree/main/app/queries) for dealing with sorting and filtering records
* I18n for all front-end content and Time formatting
* [ActiveRecord encryption](https://edgeguides.rubyonrails.org/active_record_encryption.html#setup) for secure storage of Team Oauth access_tokens
* [Slack Oauth flow](https://github.com/joshmfrankel/slack-project-coding-sample/blob/main/app/controllers/slack/oauth_callbacks_controller.rb)
* [Github CI Actions](https://github.com/joshmfrankel/slack-project-coding-sample/blob/main/.github/workflows/testing.yml) are configured to ensure Minitest is successful before merging PRs
* [Github Project](https://github.com/users/joshmfrankel/projects/5) was utilized to organize and segment work. Each unit of change is contained within a well written user story and pull request.

## Dependencies

* dotenv-rails - For EnvVar local configuration
* slack-ruby-client - For interacting with Slack API
* dry-monads - For implementing Railway Oriented Programming for Service objects
* pagy - For blazing fast Pagination
* webmock - To ensure all external requests in the test suite are stubbed
* should-context - For useful Minitest DSL syntax
* mocha - For mocking objects in Minitest
* pry - For general debugging purposes
* climate_control - For stubbing EnvVars in tests

## Future Concerns

### User Authentication

Currently, there is no User authentication for the Web UI. Since our app is already participating in Slack's OAuth flow, a good approach would be to have the User OAuth with there Slack User. This could then be utilized as their login credentials. This works nicely
since the application is predicated on the fact that they would already be utilizing Slack and would have a valid User.

### Authorization

As the Web UI grows, we'd want to implementation authorization logic to answer the following two questions:

1. Can this User perform this action?
2. Can this User interact with this resource?

Importantly, would be to segment the Incident data shown in the Web UI to only contain resources which the current_user is authorized to view. I would implement this by utilizing [Pundit](https://github.com/varvet/pundit) for creation of a new policy pattern. The current user would then be checked against the proper Policy class to determine records they can access and actions they can take.

### Token Rotation

The OAuth tokens stored in the SlackTeam table are currently not set to be rotated. Therefore they are long lasting. A good next step here would be to enable token rotation/refreshing. Currently, I have the implementation logic set to regenerate access_tokens for SlackTeam records that the team_id already exists for. This is important in case a Team removes our Slack app and reinstalls it OR they simply run through the OAuth flow process again. See documentation here: https://api.slack.com/authentication/rotation

### UI Library, Design System, & ViewComponents

The Web UI is simply a list of Incidents currently but as it grows in functionality ensuring application design cohesion will become important. One way I've accomplished this in the past is to create a standard Design System in which to base all future design solutions around. Tailwind CSS works nicely here for the foundational setup of default styling. In addition to this, crafting a UI Library with the help of ViewComponents for common front-end patterns and elements (e.g. Dropdowns, Buttons, Links).

### Background Jobs

As Web applications grow, offloading processing into asynchronous queues becomes important for complex logic. Our application is simple at the moment but there is potential for some
actions to take longer than the User expects. I would utilize [Sidekiq](https://github.com/sidekiq/sidekiq) to create a queue system for async jobs along with implementing a standard base class Job pattern.

### Monitoring

I would monitor the health and performance of our application with Honeybadger (error reporting) and Datadog (APM & metrics). Honeybadger nicely integrates into Slack as well.

### ViewComponents & Design System

As the application grows, it is important to standardize front-end components. ViewComponents give an additional layer on the standard Rails view layer similiar to the Presenter pattern. Using ViewComponents and TailwindCSS I would build a design system to ensure consistent UX throughout the application. This would also help create a common design language between Product Design, Software Engineers, and Product Directors.
