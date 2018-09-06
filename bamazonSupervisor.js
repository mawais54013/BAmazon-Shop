var inquirer = require("inquirer");
var mysql = require("mysql");
var Table = require("cli-table");
// same as the previous files to make a new connection with the same database to access 
var connection = mysql.createConnection({
    host: "localhost",
    port: 3306,

    user: "root",

    password: "password",
    database: "bamazon"
});

connection.connect(function (err) {
    if (err) throw err;
});
// except this time we use a different table to work with 
function setUp() {
    inquirer.prompt({
        name: "pick2",
        type: "list",
        message: "What would you like to do?",
        choices: [
            "View Product Sales by Department",
            "Add a New Department",
            "Exit"
        ]
    }).then(function (answer) {
        switch (answer.pick2) {
            case "View Product Sales by Department":
                showAll();
                break;

            case "Add a New Department":
                addNew();
                break;

            case "Exit":
                exit();
                break;
        }
    });
}
// this function adds a new department when selected 
function addNew()
{
    inquirer.prompt([
        {
            type: "input",
            name: "choice",
            message: "What is the name of the new department?"
        },
        {
            type: "input",
            name: "new",
            message: "What is the over head for this department?"
        }
    ]).then(function (answer) {
        console.log("Adding a new department....");
        var query = connection.query(
            "INSERT INTO departments SET ?",
            {
               department_name: answer.choice,
                over_head_costs: answer.new,
                product_sales: 0,
                total_profit: 0
            },
        );
        console.log("Successfully added " + answer.choice + " to departments");
        setUp();
    });
}
// this functions shows all the departments and their sales 
// did not use group by but rather it adds up in the customers js file whenever they buy a product 
function showAll() {
    connection.query("SELECT * FROM departments", function (err, res) {
        var table = new Table({
            head: ["Department Id", "Department Name", "Over Head Cost", "Product Sales", "Total Profits"],
            colWidths: [10,20,10,10,10]
        });

        for(var i = 0; i<res.length; i++)
        {
            table.push(
                [res[i].department_id, res[i].department_name, res[i].over_head_costs, res[i].product_sales, res[i].total_profit],
            );
        }
        console.log(table.toString());
        setUp();
    });
}
// this ends the program
function exit()
{
    connection.end();
}

setUp();

