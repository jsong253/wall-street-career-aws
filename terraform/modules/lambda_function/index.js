const registrations = [
    {
       "FirstName": "Jian",
       "LastName" : "Song",
       "DOB":"1956-06-17",
       "Email" : "songjianzhong16@gmail.com",
       "Start" : "2023-05-24",
       "End" : "2023-11-24",
       "Phone":"9522504286",
       "Active" : true
    },
    {
        "FirstName": "Yang",
        "LastName" : "Song",
        "DOB":"1956-06-17",
        "Email" : "yang.a.song@gmail.com",
        "Start" : "2023-05-24",
        "End" : "2023-11-24",
        "Phone":"9522504286",
        "Active" : true
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
   console.log(`index.js registrations start`)
   console.log(`event: ${JSON.stringify(event, null, 4)}`)

   try{
      return {
         statusCode: 200,
         headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin" : "http://localhost:3000/",
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
         },
         body:  JSON.stringify({ movies }), //sending the array of registrations as stringified JSON in the response
      };
   }
   catch(e){
      console.log(`error: ${JSON.stringify(e, null, 4)}`)
   }
   finally{
      console.log(`index.js registrations end`)
   }
};