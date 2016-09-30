class Mailer < ActionMailer::Base

  default from: 'DFM Web <dfm_web@example.com>'
  default to:   'Example Person <example@example.com>'
  layout        'mailer'


  def example(options = {})
    mail(default_params.merge(options))
  end

end
