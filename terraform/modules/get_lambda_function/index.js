// https://hands-on.cloud/terraform-api-gateway/#:~:text=Setting%20up%20the%20API%20Gateway%20Module,-At%20the%20root&text=To%20manage%20the%20API%20Gateway,or%20import%20an%20API%20key.&text=Replace%20the%20default%20value%20as,enter%20these%20values%20at%20runtime.

const registrations = [
    {
       "FirstName": "Jian",
       "LastName" : "Song",
       "DOB":"1956-06-17",
       "Email" : "songjianzhong16@gmail.com",
       "Start" : "2023-05-24",
       "End" : "2023-11-24",
       "Phone":"9522504286",
       "Active" : true,
       "password":"Jianpassword"
    },
    {
        "FirstName": "Yang",
        "LastName" : "Song",
        "DOB":"1956-06-17",
        "Email" : "yang.a.song@gmail.com",
        "Start" : "2023-05-24",
        "End" : "2023-11-24",
        "Phone":"9522504286",
        "Active" : true,
        "password":"Yangpassword"
     }
];

const movies = [
	"Schindlers List",
	"Shawshank Redemption",
	"Batman The Dark Knight",
	"Spider-Man : No Way Home",
	"Avengers",
];

exports.handler = async (event) => {
   console.log(`index.js get-registrations start`)
   // console.log(`event: ${JSON.stringify(event, null, 4)}`)
   console.log(`event.queryStringParameters: ${JSON.stringify(event.queryStringParameters, null, 4)}`)

   try{
      // need to check the passed in parameters and query the dynamoDB to see if there is a match in the registration table
      if (!event.queryStringParameters) {

         return {
   
           body: 'Query params are required',
   
           headers: {
   
             'Content-Type': 'application/json',
   
             'Access-Control-Allow-Origin': process.env.CORS_ALLOWED_ORIGIN
   
           },
   
           statusCode: 400
   
         }
   
      }

      const {email, password} = event.queryStringParameters          // destructuring to get passed in query info
      console.log(`email: ${email}`)
      console.log(`password: ${password}`)

      // TODO: do a dynamoDB query
      const filteredRegistrations =  registrations.filter(function(reg) {
         return reg.Email == email && reg.password==password;
       });
       
      return {
         statusCode: 200,
         headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Origin" : "*",
            "Access-Control-Allow-Methods": "OPTIONS,GET"
         },
         body:  JSON.stringify({ filteredRegistrations }), //sending the array of registrations as stringified JSON in the response
      };
   }
   catch(e){
      console.log(`error: ${JSON.stringify(e, null, 4)}`)
   }
   finally{
      console.log(`index.js get-registrations end`)
   }
};