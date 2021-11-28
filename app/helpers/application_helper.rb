module ApplicationHelper
  def flash_style(type)
    style = {
      alert: 'alert alert-info',
      notice: 'alert alert-success'
    }
    style[type.to_sym]
  end
end
