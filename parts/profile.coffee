if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'
    Router.route '/user/:username/cart', (->
        @layout 'layout'
        @render 'cart'
        ), name:'user_cart'
    Router.route '/user/:username/credit', (->
        @layout 'layout'
        @render 'profile'
        ), name:'user_credit'



    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username, ->

    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.profile.helpers
        user_from_username_param: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

    Template.profile.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
            
            
            
    Template.topup_button.events
        'click .topup': ->
            
            $('body').toast(
                showIcon: 'food'
                message: "100 crumbs added"
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )
            Docs.insert 
                model:'topup'
                amount:100
            Meteor.call 'calc_user_credit', Meteor.userId(), ->
            # Meteor.users.update Meteor.userId(),
            #     $inc:
            #         points:@amount
            
            
if Meteor.isClient
    Template.user_addresses.onCreated ->
        @autorun => Meteor.subscribe 'username_model_docs', 'address', Router.current().params.username, ->
            
        # if Meteor.isDevelopment
    

    Template.user_addresses.events
        'click .save_address': ->
            Session.set('editing_id',null)
        'click .edit_address': ->
            Session.set('editing_id',@_id)
        'click .remove_address': ->
            if confirm 'confirm delete?'
                Docs.remove @_id
        'click .add_address': ->
            new_id = 
                Docs.insert
                    model:'address'
            Session.set('editing_id',new_id)
            
           
           
            
    Template.user_addresses.helpers
        is_editing_address: ->
            Session.equals('editing_id',@_id)
            
            
        user_address_docs: ->
            Docs.find 
                model:'address'
                _author_username:Router.current().params.username
        
if Meteor.isServer
    Meteor.methods
        'calc_user_credit': (user_id)->
            total_points = 0
            topups = 
                Docs.find 
                    model:'topup'
                    _author_id:Meteor.userId()
                    amount:$exists:true
            for topup in topups.fetch()
                total_points += topup.amount
            console.log total_points
            
            Meteor.users.update Meteor.userId(),
                $set:points:total_points
            
            
    Meteor.publish 'username_model_docs', (model, username)->
        if username 
            Docs.find   
                model:model
                _author_username:username
        else 
            Docs.find   
                model:model
                _author_username:Meteor.user().username            
                
                
                
if Meteor.isClient
    Template.user_credit.onCreated ->
        @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'deposit'
        # @autorun => Meteor.subscribe 'model_docs', 'reservation'
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'
        @autorun => Meteor.subscribe 'my_topups'
        # if Meteor.isDevelopment
        #     pub_key = Meteor.settings.public.stripe_test_publishable
        # else if Meteor.isProduction
        #     pub_key = Meteor.settings.public.stripe_live_publishable
        # Template.instance().checkout = StripeCheckout.configure(
        #     key: pub_key
        #     image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
        #     locale: 'auto'
        #     # zipCode: true
        #     token: (token) ->
        #         # product = Docs.findOne Router.current().params.doc_id
        #         user = Meteor.users.findOne username:Router.current().params.username
        #         deposit_amount = parseInt $('.deposit_amount').val()*100
        #         stripe_charge = deposit_amount*100*1.02+20
        #         # calculated_amount = deposit_amount*100
        #         # console.log calculated_amount
        #         charge =
        #             amount: deposit_amount*1.02+20
        #             currency: 'usd'
        #             source: token.id
        #             description: token.description
        #             # receipt_email: token.email
        #         Meteor.call 'STRIPE_single_charge', charge, user, (error, response) =>
        #             if error then alert error.reason, 'danger'
        #             else
        #                 alert 'payment received', 'success'
        #                 Docs.insert
        #                     model:'deposit'
        #                     deposit_amount:deposit_amount/100
        #                     stripe_charge:stripe_charge
        #                     amount_with_bonus:deposit_amount*1.05/100
        #                     bonus:deposit_amount*.05/100
        #                 Meteor.users.update user._id,
        #                     $inc: credit: deposit_amount*1.05/100
    	# )


    Template.user_credit.events
        'click .add_credits': ->
            amount = parseInt $('.deposit_amount').val()
            amount_times_100 = parseInt amount*100
            calculated_amount = amount_times_100*1.02+20
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount
            Docs.insert
                model:'deposit'
                amount: amount
            Meteor.users.update Meteor.userId(),
                $inc: credit: amount_times_100


        'click .initial_withdrawal': ->
            withdrawal_amount = parseInt $('.withdrawal_amount').val()
            if confirm "initiate withdrawal for #{withdrawal_amount}?"
                Docs.insert
                    model:'withdrawal'
                    amount: withdrawal_amount
                    status: 'started'
                    complete: false
                Meteor.users.update Meteor.userId(),
                    $inc: credit: -withdrawal_amount

        'click .cancel_withdrawal': ->
            if confirm "cancel withdrawal for #{@amount}?"
                Docs.remove @_id
                Meteor.users.update Meteor.userId(),
                    $inc: credit: @amount

        'click .send_points': ->
            new_id = 
                Docs.insert 
                    model:'transfer'
                    amount:10
            Router.go "/transfer/#{new_id}/edit"


    Template.user_credit.helpers
        payments: ->
            Docs.find {
                model:'payment'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        deposits: ->
            Docs.find {
                model:'deposit'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1
        topups: ->
            Docs.find {
                model:'topup'
                _author_username: Router.current().params.username
            }, sort:_timestamp:-1




    Template.user_credit.events
        'click .add_credit': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.users.update Meteor.userId(),
                $inc:points:10
                # $set:points:1
        'click .remove_points': ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Meteor.users.update Meteor.userId(),
                $inc:points:-1
        'click .add_credits': ->
            deposit_amount = parseInt $('.deposit_amount').val()*100
            calculated_amount = deposit_amount*1.02+20
            
            # Template.instance().checkout.open
            #     name: 'credit deposit'
            #     # email:Meteor.user().emails[0].address
            #     description: 'gold run'
            #     amount: calculated_amount



    Template.user_dashboard.onCreated ->
        # @autorun => Meteor.subscribe 'user_current_reservations', Router.current().params.username
    Template.user_dashboard.helpers

    Template.user_dashboard.events
            
            
if Meteor.isServer
    Meteor.publish 'my_topups', ->
        Docs.find 
            model:'topup'
            _author_id:Meteor.userId()  
            amount:$exists:true