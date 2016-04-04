#--------------------------- Main application ----------------------------------

@MainApp = (message1, message2, tokens_path, token_CSRF) ->

  # variables for activation request form
  @input1 = document.getElementById('MAC')
  @input2 = document.getElementById('name')
  @requestButton = document.getElementById('requestButton')

  # variables for user approve token form
  @input3 = document.getElementById('token')
  @tokenButton = document.getElementById('verificationButton')

  # variables for output form (showing activation statuses and tokens)
  @answer1 = document.getElementById('answer1')
  @answer2 = document.getElementById('answer2_2')
  @activationStatus = document.getElementById('answer2_1')

  # variables for flash messages
  @flash = document.getElementById('InformationBlock')
  @message1 = message1
  @message2 = message2

  # Rails tokens_path (used in CheckActivation) and CSRF token for form sending
  @tokens_path = tokens_path
  @token_CSRF = token_CSRF

  # button listeners
  ButtonListener1 tokens_path, token_CSRF
  ButtonListener2 tokens_path, token_CSRF if @tokenButton # if user logged in
  return

#------ It checks if button for emulating device request is pressed ------------

ButtonListener1 = ->
  requestButton.onclick = ->

    # cleans form fields
    activationStatus.innerHTML = "..."
    answer1.innerHTML = "..."
    answer2.innerHTML = "..."
    input3.value = "" if input3

    # sends data
    SendForm()
    return
  return

#------------------ It sends form with device MAC and name ---------------------

SendForm = ->
  form = new FormData
  form.append 'device[MAC]', input1.value
  form.append 'device[name]', input2.value

  # send request
  xhr = new XMLHttpRequest
  xhr.open 'POST', tokens_path, true
  xhr.setRequestHeader 'X-CSRF-Token', token_CSRF
  xhr.setRequestHeader 'X-Requested-With', 'XMLHttpRequest'
  xhr.send form
  xhr.onload = ->
    responseData = JSON.parse this.responseText

    # cleans messages if they exist prepares new and shows error messages
    if responseData.status == "errors"
      flash.innerHTML = ''
      window.location = window.location.pathname + "#"
      for i in [0 ... responseData.errors.length]
        div = document.createElement "div"
        alert = document.createTextNode responseData.errors[i]
        div.className = 'AlertInformation'
        div.appendChild alert
        flash.appendChild div

    # cleans messages if they exist and starts checking activation
    else if responseData.status == "Ok"
      answer1.innerHTML = responseData.token
      flash.innerHTML = ''
      CheckActivation responseData.token
      window.location = window.location.pathname + "#bottom"
    return
  return

#------------- Timer (Repeater) for asking device activation -------------------

CheckActivation = (token) ->

  # destroys itself if user go to different page or status is "Activated"
  repeater = setInterval ->
    if window.location.pathname != tokens_path and
       window.location.pathname != '/'
      clearInterval(repeater)
    if activationStatus.innerHTML == "Activated"
      clearInterval(repeater)
    else
      Checker(token) # asks server every 2 seconds (kind of DDOS)
    return
  ,2000
  return

#---- It asks server if device is activated and shows statuses and tokens ------

Checker = (token) ->
  xhr = new XMLHttpRequest
  xhr.open "get", tokens_path + "/" + token, true
  xhr.setRequestHeader 'X-CSRF-Token', token_CSRF
  xhr.setRequestHeader 'X-Requested-With', 'XMLHttpRequest'
  xhr.send()
  xhr.onload = ->
    responseData = JSON.parse this.responseText
    if responseData.status == "Activated"
      activationStatus.innerHTML = "Activated"
      answer2.innerHTML = responseData.token
    else if responseData.status == "NoChanges"
      activationStatus.innerHTML = "No Changes"
      answer2.innerHTML = "No Token"
  return

#---------- It checks if button for device binding is pressed ------------------

ButtonListener2 = ->
  tokenButton.onclick = ->
    data = input3.value
    data = "none" until data # if user sent empty token
    path = tokens_path + "/" + data
    SendForm2 path
    return
  return

#-------------- It sends form when user approves device binding ----------------

SendForm2 = (path) ->
  form = new FormData
  form.append 'device[token]', input3.value

  xhr = new XMLHttpRequest
  xhr.open 'PATCH', path, true
  xhr.setRequestHeader 'X-CSRF-Token', token_CSRF
  xhr.setRequestHeader 'X-Requested-With', 'XMLHttpRequest'
  xhr.send form
  xhr.onload = ->
    responseData = JSON.parse this.responseText

    # cleans messages if they exist and shows that nothing is changed
    if responseData.status == 'NoChanges'
      flash.innerHTML = ''
      window.location = window.location.pathname + "#"
      div = document.createElement("div")
      alert = document.createTextNode(message1)
      div.className = 'AlertInformation'
      div.appendChild alert
      flash.appendChild div

    # cleans messages if they exist and shows activation success message
    else if responseData.status == "Activated"
      flash.innerHTML = ''
      window.location = window.location.pathname + '#'
      div = document.createElement('div')
      alert = document.createTextNode(message2)
      div.className = 'CommonInformation'
      div.appendChild alert
      flash.appendChild div
    return
  return

