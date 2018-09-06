var mysql = require("mysql");
var inquirer = require("inquirer");
var Table = require("cli-table");
var figlet = require("figlet");
// i used four npm 
// one for mysql, one for request one table display, and the last one is a design to welcome the customer
var connection = mysql.createConnection({
    host: "localhost",
    port: 3306,

    user: "root",

    password: "password",
    database: "bamazon"
});
// create connection and use the information from the database
connection.connect(function (err) {
    if (err) throw err;
});
// this is used to create the welcome display for the customer
    figlet('Welcome', function(err, data) {
        if (err) {
            console.log('Something went wrong...');
            console.dir(err);
            return;
        }
        console.log(data)
    });
// this setup function is the first to work that is selects from products to make a table and lets the user pick what they want to do.
function setUp() {
    connection.query("SELECT * FROM products", function (err, res) {
        var table = new Table({
            // make a new table 
            head: ["Item Id", "Product Name", "Department", "Price", "Quantity"],
            colWidths: [10, 20, 15, 10, 10]
        });
        // push the information to tables
        for (var i = 0; i < res.length; i++) {
            table.push(
                [res[i].Item_id, res[i].Product_name, res[i].Department_name, res[i].Price, res[i].Stock_Available],
            );
        }
        console.log(table.toString());
        inquirer.prompt([
            {
                // ask first if they would like to shop
              type: "input",
                name: "choice2",
                message: "Would you like to shop [yes or no]?"
            }
        ]).then(function(pick2)
            {
                // then based on the response the function can do two things
                if(pick2.choice2 == "yes")
                {
                    doThing();
                }
                // if they select no then the program ends 
                else if(pick2.choice2 === "no")
                {
                    connection.end();
                }
                
            })
        // doThing();
    });
}

function doThing() {
    // makes space
    // console.log('\n  ');
    connection.query("SELECT * FROM products", function (err, res) {
        inquirer.prompt([
            {
                // this asks the user what product they would like to buy 
                type: "input",
                name: "input1",
                message: "What is the ID of the product you would like to purchase?",
                // the value must be a number or it will not accept it
                validate: function (value) {
                    if (isNaN(value) === false) {
                        return true;
                    }
                    return false;
                }
            }
        ]).then(function (answer) {
            // once they have selected then this loop goes through the database to match the id with the user answer to get all the information about that product
            var chosen;
            for (var i = 0; i < res.length; i++) {
                if (res[i].Item_id == answer.input1) {
                    chosen = res[i];
                    // console.log(chosen);
                    // then this goes to another function
                    check(chosen);
                }
            }
        });

    });
}

// this function asks the user how many the user would like the product
function check(input) {
    // console.log(input);
    inquirer.prompt([{
        name: "pick",
        type: "input2",
        message: "How many would you like?",
        validate: function (value) {
            // same thing this value must be a number
            if (isNaN(value) === false) {
                return true;
            }
            return false;
        }
    }]).then(function (answer) {
        // console.log(answer.pick)
        // console.log(input.Stock_Available);
        // this sets the updated numbers to the database
        var sale = 0;
        var totalSales = input.Price * answer.pick;
        var sales = sales + answer.pick;
        var diff = input.Stock_Available - answer.pick;
        // if the quantity is less than the user pick then it prints this 
            if(input.Stock_Available < answer.pick)
            {
                // console.log("Sorry we are out of stock");
                console.log("Insufficient quantity!");
                setUp();
            }
            else 
            { 
                connection.query(
                    // this updates products from database with the id of the product to the new quantity
                    "UPDATE products SET ? WHERE ?",
                    [
                        {
                            Stock_Available: diff
                        },
                        {
                            Item_id: input.Item_id
                        }
                    ],
                    // this does nothing
                    function(err, res)
                    {
                        // console.log("Updated " + JSON.stringify(res));
                        // console.log("Successfully Purchased " + input.Product_name);
                        // setUp();
                    }
                )
                // this is used to update the sales of each product once the user buys them and only the manger can look at this
                connection.query(
                    "UPDATE products SET ? WHERE ?",
                    [
                        {
                            Product_sale: sales
                        },
                        {
                            Item_id: input.Item_id
                        }
                    ],
                    function(err, res)
                    {
                        // console.log("Updated " + JSON.stringify(res));
                        console.log("Successfully Purchased " + input.Product_name);
                        setUp();
                    }
                )
                // this updates the sales of the total department that can only be viewed by the supervisor
                connection.query(
                    "UPDATE departments SET ? WHERE ?",
                    [
                        {
                            product_sales: totalSales
                        },
                        {
                            department_name: input.Department_name
                        }
                    ],
                    // this does nothing
                    function(err, res)
                    {

                    }
                )
            }
    });
}

setUp();