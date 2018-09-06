var inquirer = require("inquirer");
var mysql = require("mysql");
var Table = require("cli-table")
// this creates a connection for mysql database 
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
// this asks the manager what they would like to do
function setUp() {
    inquirer.prompt({
        name: "pick",
        type: "list",
        message: "What would you like to do?",
        // with choices the user must select
        choices: [
            "View Products for Sale",
            "View Low Inventory",
            "Add to Inventory",
            "Add New Product",
            "Exit"
        ]
    }).then(function (answer) {
        // if used a switch case instead of if for practice 
        // pretty much if they select one of the choices then a function will happen
        switch (answer.pick) {
            case "View Products for Sale":
                show();
                break;

            case "View Low Inventory":
                inventory();
                break;

            case "Add to Inventory":
                lowInv();
                break;

            case "Add New Product":
                product();
                break;

            case "Exit":
                leave();
                break;
        }
    });
}
// this function ask the user what item they would like to add along with the relevant information about the product
function product() {
    inquirer.prompt([
        {
            type: "input",
            name: "item",
            message: "What is the name of the item you would like to add?"
        },
        {
            type: "input",
            name: "price",
            message: "What is the price of this item"
        },
        {
            type: "list",
            name: "cate",
            message: "What department would you like this item to be in?",
            choices: ["Tech", "Movies", "Clothing", "Stationary", "Household", "Toys", "Home Improvement", "Food"]
        },
        {
            type: "input",
            name: "many",
            message: "How many do you currently have?"
        }
    ]).then(function (answer1) {
        // this inserts the new product into the database and updates it
        console.log("Inserting a new product...");
        var query = connection.query(
            "INSERT INTO products SET ?",
            {
                Product_name: answer1.item,
                Department_name: answer1.cate,
                Product_sale: 0,
                Price: answer1.price,
                Stock_Available: answer1.many 
            },
        );
        console.log("Successfully added " + answer1.item + " to inventory");
        setUp();
    });
}
// this functions adds more inventory to products 
function lowInv() {
    connection.query("SELECT * FROM products", function (err, res) {
        // ask about the product
        inquirer.prompt([
            {
                type: "input",
                name: "change",
                message: "Which product would you like to add more inventory to?",
                validate: function (value) {
                    if (isNaN(value) === false) {
                        return true;
                    }
                    return false;
                }
            }]).then(function (answer) {
                var picked;
                // console.log(answer.change);
                for (var i = 0; i < res.length; i++) {
                    // then transfers this input to another functions that adds more inventory 
                    if (res[i].Item_id == answer.change) {
                        picked = res[i];
                        changeInvent(picked);
                    }
                }
                setUp();
            });
    });
}

function changeInvent(chosen) {
    // console.log(chosen);
    // ask the user of how much they would like to add 
    inquirer.prompt([
        {
            name: "amount",
            type: "input",
            message: "How much would you like to add?",
            validate: function (value) {
                if (isNaN(value) === false) {
                    return true;
                }
                return false;
            }
        }]).then(function (answers) {

            // then updates the current products database with the number the user picked  
            var stock = parseInt(answers.amount);
            var plus = chosen.Stock_Available + stock;
            connection.query("UPDATE products SET ? WHERE ?",
                [
                    {
                        Stock_Available: plus
                    },
                    {
                        Item_id: chosen.Item_id
                    }
                ],
                function (err, res) {
                    console.log("Successfully added " + plus + " inventory to " + chosen.Product_name);
                    setUp();
                }
            )
        });
}
// ends the program
function leave() {
    connection.end();
}
// this functions shows the products available along with the sales of each product
function show() {
    connection.query("SELECT * FROM products", function (err, res) {
        // create a new table 
        var table = new Table({
            head: ["Item Id", "Product Name", "Sales", "Department", "Price", "Quantity"],
            colWidths: [10, 20, 10, 15, 10, 10]
        });
// goes through loop to get information about each product and shows themm 
        for (var i = 0; i < res.length; i++) {
            table.push(
                [res[i].Item_id, res[i].Product_name, res[i].Product_sale, res[i].Department_name, res[i].Price, res[i].Stock_Available],
            );
        }
        console.log(table.toString());
        setUp();
    });
}
// this functions shows a new table for products that have low inventory 
function inventory() {
    connection.query("SELECT * FROM products", function (err, res) {
        var table1 = new Table({
            head: ["Item Id", "Product Name", "Sales", "Department", "Price", "Quantity"],
            colWidths: [10, 20, 10, 15, 10, 10]
        });
// this only shows those products that have inventory lower than 20. 
        for (var x = 0; x < res.length; x++) {
            if (res[x].Stock_Available < 20) {
                table1.push(
                    [res[x].Item_id, res[x].Product_name, res[x].Product_sale, res[x].Department_name, res[x].Price, res[x].Stock_Available],
                );
            }
        }
        console.log(table1.toString());
        setUp();
    });
}

setUp();