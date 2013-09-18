  # $('#freelancer_status').val('aadafasdfadsf')
window.onload = ->
  $('#freelancer_status_text img').click ->
    change_status()

  change_status = ->
    status = $('#freelancer_status').val()
    if status == 'available'
      status = 'shortly'
    else if status == 'shortly'
      status = 'working'
    else
      status = 'available'

    $.ajax
      type: 'POST'
      url: 'change_status'
      data: {user:{status: status}}
      async: false
      success: (data)->
        $('#freelancer_status').val(status)
        $('#freelancer_status_text a img').attr('src', "/assets/freelance/#{status}.png")

  endorseUser = (skill_type, skill_id)->
    $.ajax
      type: 'PUT'
      url: '/freelancers/endorse/skill'
      data:
        skill_type: skill_type
        skill_id: skill_id
        username: $('#freelancer').val()
      success: (data) ->
      error: (data) ->
        id = "#recommender_"+ skill_type + "_" + skill_id
        img_id = "##{skill_type}_#{skill_id}"
        $(id).append(data.responseText)
        $(img_id).attr('src', '/assets/freelance/liked.png')
        $(img_id).parent().addClass('like-disable')
        $(img_id).parent().removeClass('like')
        $(img_id).removeClass()
        $(img_id).unbind('click')


  $('.likebtn').click ->
    endorseUser(this.id.split(/_/)[0], this.id.split(/_/)[1])
    $(this).unbind('click')


  filterFreelancers = (platforms_in, languages_in)->
    $.ajax
      type: "GET"
      url: "/freelancers"
      data:
        search:
          platforms_in: platforms_in
          languages_in: languages_in
          developer: $('#discipline').val()
          browse_all: $('#browse_all').is(":checked").toString()
      dataType: "json"
      beforeSend: ->
        $('#loading').css('display', 'block')
      success: (data) ->
        console.log('success...')
        $("#details-panel").html data
        rebindEvent()
      complete: ->
      error: (error) ->
        console.log('error...')
        $("#details-panel").html error.responseText
        $('#loading').css('display', 'none')
        rebindEvent()
        rebindMoreLinks()

  getIds = (div) ->
    if div == '#dialogP' || div == '#platforms'
      div1 = '#dialogP'
      div2 = '#platforms'
    else
      div1 = '#dialogL'
      div2 = '#languages'
    ids(div1).concat(ids(div2))

  ids = (div) ->
    $(div + " input[type=checkbox]:checked").map(->
      @value
    ).get()

  $("#search-panel :checkbox").click ->
    filterFreelancers(getIds('#platforms'), getIds('#languages'))

  filterFreelancersPopup = (div) ->
    platforms_in = getIds('#platforms')
    languages_in = getIds('#languages')
    filterFreelancers(platforms_in, languages_in)


  $(".dialogP").each ->
    id = "##{$(this).attr('id')}"
    $(id).dialog
      resizable: false
      height: 240
      width: 600
      modal: true
      buttons:
        Filter: ->
          filterFreelancersPopup("#dialogP")
          $(this).dialog "close"
        Cancel: ->
          $(this).dialog "close"
    $(id).dialog "close"

  $(".dialogL").each ->
    id = "##{$(this).attr('id')}"
    $(id).dialog
      resizable: false
      height: 240
      width: 600
      modal: true
      buttons:
        Filter: ->
          filterFreelancersPopup("#dialogL")
          $(this).dialog "close"
        Cancel: ->
          $(this).dialog "close"

    $(id).dialog "close"

  $("#all-plat").click ->
    id = "#dialogP-#{$('#discipline').val()}"
    $(id).dialog "open"

  $("#all-lang").click ->
    id = "#dialogL-#{$('#discipline').val()}"
    $(id).dialog "open"

  $('#discipline').change ->
    refresh_checkboxes()
    filterFreelancers([], [])

  refresh_checkboxes = ->
    $('.display_items').css('display', 'none')
    $('.display_items :checked').removeAttr('checked')
    id = "#disp-"+$('#discipline').val()
    $(id).css('display','block')
    $(id).css('display','block')
    id = "#disl-"+$('#discipline').val()
    $(id).css('display','block')
    id = "#dialogL-#{$('#discipline').val()}"
    if $(id).length > 0
      $("#all-lang").css('display', 'block')
    else
      $("#all-lang").css('display', 'none')

    id = "#dialogP-#{$('#discipline').val()}"
    if $(id).length > 0
      $("#all-plat").css('display', 'block')
    else
      $("#all-plat").css('display', 'none')

  $('#add-more').click ->
    $('#add-more-links').toggle()
    $(this).css('display', 'none')
  $('#cancel').click ->
    $('#add-more-links').toggle()
    $('#add-more').css('display', 'block')
    $('#user_link').val('')

  $('#add').click ->
    $.ajax
      type: 'PUT'
      url: '/freelancers/add/user_link'
      data:
        user_link: $('#user_link').val()
      success: (data) ->
        html = "<div class='personal-url' id='user-link-#{data.id}'><div class='info'><div class='name'><h5><a href='#{data.link_url}'>#{data.name}</a></h5></div><div class='delete'><a href='javascript:void(0)' data-method='delete' onclick='remove_link(#{data.id})'>remove</a></div></div><hr></div>"
        $('.links').append(html)
        $('#add-more-links').toggle()
        $('#add-more').css('display', 'block')
        $('#user_link').val('')
      error: (data) ->
        console.log('error')

  $('#require-login').dialog
      height: 200
      width: 350
      modal: true
      buttons:
        Ok: ->
          $(this).dialog('close')
  $('#require-login').dialog('close')

  $('.liked img').click ->
    $('#require-login').dialog('open')
    
  window.fetch_more = (id)->
    $.ajax
      type: "GET"
      url: "/freelancers/fetch/more"
      data:
        platforms_in: getIds('#platforms')
        languages_in: getIds('#languages')
        discipline_id: $('#discipline').val()
        status: id
      dataType: "json"
      beforeSend: ->
        console.log(id)
        console.log(".#{id} #error-div")
        console.log('----')
        $(".#{id} #error-div").remove()
      success: (data) ->
        $(".#{id} #endorsings").append data
      complete: ->
      error: (data) ->
        $(".#{id} #endorsings").append data.responseText
        rebindEvent()

  window.rebindMoreLinks = ->
    console.log('rebinding event...')
    $('.more-freelancers a').click ->
      id = "#{$(this).parent().attr('id')}"
      fetch_more(id)
      $(this).unbind('click')
      
  window.rebindEvent = ->

    $(".companies").each ->
      id = "##{$(this).attr('id')}"
      $(id).dialog
        resizable: false
        height: 200
        width: 350
        modal: true
        buttons:
          Ok: ->
            $(this).dialog('close')
      console.log('closing...'+id)
      $(id).dialog "close"
    $(".ui-dialog-content").dialog("close");

    $('.company').click ->
      console.log('open dialog...')
      id = "#{$(this).attr('id')}"
      # id = id.split('-')[1]
      id = id.replace('company', 'companies')
      id = "##{id}"
      console.log(id)
      $(id).dialog 'open'

  rebindEvent()
  rebindMoreLinks()