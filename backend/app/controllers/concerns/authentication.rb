module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    before_action :extend_session
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      skip_before_action :extend_session, **options
    end
  end

  private
    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      return unless cookies.signed[:session_id]
      Session.active.find_by(id: cookies.signed[:session_id])
    end

    def extend_session
      Current.session&.touch_if_stale
    end

    def request_authentication
      render_unauthorized("認証が必要です")
    end

    def start_new_session_for(user)
      user.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      ).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = {
          value: session.id,
          httponly: true,
          secure: Rails.env.production?,
          same_site: :lax,
          path: "/"
        }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
