class Mailer < ActionMailer::Base

  default from: 'DFM Web <dfm_web@example.com>'
  default to:   'Example Person <example@example.com>'
  default content_type: 'text/html'
  layout        'mailer'


  def example(options = {})
    mail(options)
  end

end
