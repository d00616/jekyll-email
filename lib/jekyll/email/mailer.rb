module Jekyll
  module Email
    class Mailer
      attr_reader :is_smtp

      OPTIONS = { address:              ENV['MAIL_HOST'],
                  port:                 ENV['MAIL_PORT'],
                  domain:               ENV['MAIL_DOMAIN'],
                  user_name:            ENV['MAIL_USER'],
                  password:             ENV['MAIL_PASSWORD'],
                  authentication:       'plain',
                  enable_starttls_auto: true
                }

      def initialize(smtp = true)
        @is_smtp = smtp
        delivery = smtp ? :smtp : LetterOpener::DeliveryMethod
        options = smtp ? OPTIONS : { location: File.expand_path('../tmp/letter_opener', __FILE__) }

        Mail.defaults do
          delivery_method delivery, options
        end
      end

      def deliver(recipients, subject, body)
        recipients = [recipients.first] unless is_smtp

        recipients.each do |recipient|
          output_message = is_smtp ? "sending to #{recipient}..." : "opening in your browser..."
          puts output_message

          deliver_to_recipient(recipient, subject, body)
        end
      end

      private

      def deliver_to_recipient(recipient, subject, body)
        Mail.deliver do
          from    ENV['MAIL_FROM']
          to      recipient
          subject subject

          html_part do
            content_type 'text/html; charset=UTF-8'
            body body
          end
        end
      end
    end
  end
end
