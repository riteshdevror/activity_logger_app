# Activity Logger App
[![Ruby](https://img.shields.io/badge/Ruby-3.2.2-red.svg)](https://ruby-lang.org)
[![Rails](https://img.shields.io/badge/Rails-7.1-blue.svg)](https://rubyonrails.org)

A modern Ruby on Rails application that tracks project conversations by logging both comments and status changes. This app provides a unified conversation history for each project, making it easy for users to review all activities at a glance.

## Overview

**Activity Logger App** is designed to streamline project communication. With this app, users can:

- **💬 Leave Comments:** Engage in discussions about projects.
- **🛠️ Change Project Status:** Easily update the status (open, in_progress, closed) of any project.
- **🔄 Review Activity:** View a combined, chronological conversation history that includes both status changes and comments.

---

## Features

- **Unified Conversation History:**  
  🔄 Combines comments and status changes into one chronological timeline.
- **Interactive Commenting:**  
  💬 Users can leave comments on projects.
- **Dynamic Status Updates:**  
  🛠️ Update a project's status using an intuitive interface.
- **Automated Activity Logging:**  
  📝 All changes are automatically logged via a custom `ActivityAudit`.
- **Responsive Design:**  
  📱 Built with Tailwind CSS for a modern, mobile-friendly UI.
- **Secure User Authentication:**  
  🔒 Powered by Devise for robust security.

## Tech Stack

- **Ruby:** 3.2.2
- **Ruby on Rails:** 7.1
- **PostgreSQL:** Primary database
- **Tailwind CSS:** For styling and responsive design
- **Devise:** For user authentication
- **RSpec & FactoryBot:** For automated testing

## Getting Started

Follow these instructions to get a development copy up and running on your local machine.

### Prerequisites

- Ruby (3.2.2 or your version)
- Rails (7.1)
- PostgreSQL
- Node.js & Yarn (for asset management with Tailwind CSS)

### Installation

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/riteshdevror/activity_logger_app
   cd activity_logger_app
2. **Install Ruby Gems:**
   ```bash
   bundle install
3. **Install Node Modules:**

   ```bash
   yarn install
### Database Setup
  1. **Create the Database::**

    rails db:create

  2. **Migrate the Database::**

    rails db:migrate

  3. **Precompile Assets::**

    rails assets:precompile

  4. **Start the Server:**

    rails s
### Activity Audit Uses 
  ```ruby
  class Project < ApplicationRecord
    include ActivityAudit # Add Concern
    activity_attr :status # Specify fields to track activities
  end

  class Comment < ApplicationRecord
    include ActivityAudit  # Add Concern
    activity_attr :content # Specify fields to track activities
  end
  ```
### Activity Audit 
   ```ruby
      module ActivityAudit
        extend ActiveSupport::Concern

        included do
          class_attribute :tracked_attributes
          self.tracked_attributes = []

          after_create  :log_create_activity
          after_update  :log_update_activity
          before_destroy :log_delete_activity
        end

        class_methods do
          def activity_attr(*attrs)
            self.tracked_attributes = attrs.map(&:to_s)
          end
        end

        private

        def log_create_activity
          log_activity(:create, tracked_attributes)
        end

        def log_update_activity
          log_activity(:update, saved_changes.keys & tracked_attributes)
        end

        def log_delete_activity
          log_activity(:delete, tracked_attributes)
        end

        def log_activity(action, changed_fields)
          return if changed_fields.empty?

          changed_fields.each do |field|
            ::ActivityLogger.create(
              trackable: self,
              action: action,
              field_name: field,
              previous_value: value_for(:previous, field, action),
              new_value: value_for(:new, field, action)
            )
          end
        end

        def value_for(value_type, field, action)
          mapping = {
            previous: {
              create: -> { nil },
              update: -> { saved_changes.dig(field, 0) },
              delete: -> { self[field] }
            },
            new: {
              create: -> { self[field] },
              update: -> { saved_changes.dig(field, 1) },
              delete: -> { nil }
            }
          }
          mapping.fetch(value_type, {}).fetch(action, -> { nil }).call
        end
      end
```
### Testing 🧪

Run our comprehensive test suite to ensure that every component of the **Activity Logger App** is functioning flawlessly. Execute the following command in your terminal:

```bash
bundle exec rspec
