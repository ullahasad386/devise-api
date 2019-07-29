class Api::V1::RegistrationsController < Devise::RegistrationsController
  before_action :ensure_params_exist, only: [:create]

  def create
    user = User.new user_params
    if user.save
      render json: { meta: {status: 'SUCCESS', code: 200, message: 'Signed up successfully'}, data: { user: user } },
    status: :ok
    else
      render json: { meta: {status: 'ERROR', code: 422, message: 'Something went wrong'}, data: {} },
    status: :unprocessible_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def ensure_params_exist
    return if params[:user].present?
    render json: { meta: {status: 'ERROR', code: 400, message: 'Missing params'}, data: {} },
  status: :bad_request
  end

end
