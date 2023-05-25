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
	return {
		statusCode: 200,
		headers: {
			"Content-Type": "application/json",
		},
		body:  JSON.stringify({ movies }), //sending the array of registrations as stringified JSON in the response
	};
};