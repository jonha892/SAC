defmodule SAC.Email do
    import Bamboo.Email

    def buildReportMail(recipients, subject, body) do
        sender = Application.fetch_env!(:sac, :sender)

        new_email(
            from: sender,
            to: recipients,
            subject: subject,
            text_body: body,
        )
    end
end
