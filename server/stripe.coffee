stripe = require('stripe')('sk_test_5103F9t2l80WEvLLPcQfRPWGFslvo4htyZRCjRQ4YQ8DnRO0Qp18WNWRw7KSOxX9N0f45WU0eYeGXpkAx9MnXkaa700I9qwX0HQ');
Meteor.methods
  stripe_checkout: ()=>
    # console.log 'stripe', stripe
    # paymentIntent = stripe.paymentIntents.create({
    #   amount: 1000,
    #   currency: 'usd',
    #   payment_method_types: ['card'],
    #   receipt_email: 'jenny.rosen@example.com',
    # });
    session = stripe.checkout.sessions.create({
      line_items: [{
        price: 'business',
        quantity: 1,
      }],
      mode: 'subscription',
      success_url: 'https://example.com/success',
      cancel_url: 'https://example.com/failure',
    });
    result = Promise.await(session)

    console.log result
    #   payment_intent_data: {
    #     application_fee_amount: 123,
    #     transfer_data: {
    #       destination: 'test',
    #     },
    #   },
    console.log session
    session


Meteor.methods
  list_customers: ()=>
    # console.log 'stripe', stripe
    # paymentIntent = stripe.paymentIntents.create({
    #   amount: 1000,
    #   currency: 'usd',
    #   payment_method_types: ['card'],
    #   receipt_email: 'jenny.rosen@example.com',
    # });
    result = Promise.await(stripe.customers.list({}))
    console.log result
    # results = Promise.await
    # session = stripe.checkout.sessions.create({
    #   line_items: [{
    #     price: 'business',
    #     quantity: 1,
    #   }],
    #   mode: 'subscription',
    #   success_url: 'https://example.com/success',
    #   cancel_url: 'https://example.com/failure',



# stripe = require('stripe')
# # ('sk_test_5103F9t2l80WEvLLPcQfRPWGFslvo4htyZRCjRQ4YQ8DnRO0Qp18WNWRw7KSOxX9N0f45WU0eYeGXpkAx9MnXkaa700I9qwX0HQ');

# YOUR_DOMAIN = 'http://localhost:4242';

# # app.post('/create-checkout-session', async (req, res) => {
# Meteor.methods 
#     stripe: (req, res) =>
#         console.log 'stripe', stripe
#         session = stripe.checkout.sessions.create({
#             line_items: [
#                 {
#                 # // Provide the exact Price ID (for example, pr_1234) of the product you want to sell
#                     price: 'business',
#                     quantity: 1,
#                 },
#             ],
#             mode: 'payment',
#             success_url: "#{YOUR_DOMAIN}/success.html",
#             cancel_url: "#{YOUR_DOMAIN}/cancel.html",
#       })