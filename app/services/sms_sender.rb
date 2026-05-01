# app/services/sms_sender.rb
class SmsSender
  def self.send_hello(to:)
    client = Twilio::REST::Client.new(
      ENV.fetch("TWILIO_ACCOUNT_SID"),
      ENV.fetch("TWILIO_AUTH_TOKEN")
    )

    client.messages.create(
      from: ENV.fetch("TWILIO_PHONE_NUMBER"),
      to: to,
      body: "Hello world from aws_pet_tracking_app!"
    )
  end
end