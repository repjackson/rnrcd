Router.route '/admin', -> @render 'admin'
            
if Meteor.isServer
    Meteor.publish 'admin_settings', ->
        Docs.find 
            model:'admin_settings'