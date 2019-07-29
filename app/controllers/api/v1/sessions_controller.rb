class Api::V1::SessionsController < Devise::SessionsController
  before_action :sign_in_params, only: [:create]
  before_action :load_user, only: [:create]
  before_action :valid_token, only: [:destroy]
  skip_before_action :verify_signed_out_user, only: [:destroy]

  def create
    if @user.valid_password?(sign_in_params[:password])
      sign_in "user", @user
      render json: { meta: {status: 'SUCCESS', code: 200, message: 'Signed in successfully'}, data: {user: @user} },
        status: :ok
    else
      render json: { meta: {status: 'ERROR', code: 401, message: 'Unauthorized'}, data: {} },
        status: :unauthorized
    end
  end

  def destroy
    sign_out @user
    @user.generate_new_authentication_token
    render json: { meta: {status: 'SUCCESS', code: 200, message: 'Logged out successfully'}, data: {} },
  status: :ok
  end

  private

  def sign_in_params
    params.require(:sign_in).permit(:email, :password)
  end

  def load_user
    @user = User.find_for_database_authentication(email: sign_in_params[:email])
    if @user
      return @user
    else
      render json: { meta: {status: 'ERROR', code: 403, message: 'Cannot get user'}, data: {} },
    status: :failure
    end
  end

  def valid_token
    @user = User.find_by authentication_token: request.headers["AUTH-TOKEN"]
    if @user
      return @user
    else
      render json: { meta: {status: 'ERROR', code: 403, message: 'Invalid token'}, data: {} },
    status: :failure
  end
end

end
