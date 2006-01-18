class <%= class_name %>Controller < ApplicationController
  # The following line defines methods that implement the OpenLaszlo
  # REST API.
  #
  # To replace this file with a file that contains explicit method
  # definitions, execute:
  #   script/generate rest_scaffold <%= singular_name %>
  rest_scaffold :<%= singular_name %>
end
