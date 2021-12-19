var path = require('path');
var p = path.join(__dirname, 'obj.json');
var d = path.join(__dirname, 'descriptions.json');
var t = path.join(__dirname, 'test.json');

var fs = require('fs');
var data;
var tests;
var descriptions
var class_test

fs.readFile(t, 'utf8', function (err, tests_json) {
    if (err) return console.log(err);
    tests = JSON.parse(tests_json);

    fs.readFile(p, 'utf8', function (err, data_json) {
        if (err) return console.log(err);
        data = JSON.parse(data_json);
        fs.readFile(d, 'utf8', function (err, descriptions_json) {
            if (err) return console.log(err);
            descriptions = JSON.parse(descriptions_json);
            build_accordion(data, descriptions)
        });
    })
})

function build_accordion(data, descriptions) {

    const accordion_root = $("#accordion")
    $("#accordion").html('')
    $.each(data, function (e, o) {

        const accordion_item = document.createElement('div');
        $(accordion_item).addClass("accordion-item")
            .appendTo($("#accordion")) //main div

        const item_header = document.createElement('h2');
        $(item_header).addClass("accordion-header")
            .attr('id', `heading_${e}`)
            .appendTo(accordion_item)

        const des = e
//      const des = descriptions[e]?.Spanish.Title ? descriptions[e]?.Spanish.Title : e /// DEBUG MODE ON

        const item_button = document.createElement('button');
        $(item_button).addClass("accordion-button")
            .attr({
                'type': `button`,
                'data-bs-toggle': 'collapse',
                'data-bs-target': `#collapse_${e}`,
                'aria-expanded': 'true',
                'aria-controls': `collapse_${e}`
            }).text(des)
            .appendTo(item_header)

        const item_collapse = document.createElement('div');
        $(item_collapse).addClass("accordion-collapse")
            .addClass("collapse")
            .addClass("show")
            .attr({
                'id': `collapse_${e}`,
                'aria-labelledby': `heading_${e}`,
                //'data-bs-parent': '#accordion',
            }).appendTo(accordion_item)

        const item_body = document.createElement('div');
        $(item_body).addClass("accordion-body")
            .appendTo(item_collapse)
            .next(show_description(e, descriptions, item_body))
            .next(show_table(e, o, item_body))
    })
}

function show_description(e, descriptions, item_body) {

    const description_div = document.createElement('div');
    $(description_div).appendTo(item_body)

    const p = document.createElement('p');
    $(p).text(descriptions[e]?.Spanish.Description)
        .appendTo(description_div)

}


function show_table(e, o, item_body) {

    o = Array.isArray(o)?o:[o];

    const table = document.createElement('table');
    $(table).addClass("table")
        .addClass("table-hover")
        .addClass("table-bordered")
        .attr('id', `id=target_table_${e}`)
        .appendTo(item_body)

    const thead = document.createElement('thead')
    $(thead).appendTo(table)

    const tr = document.createElement('tr')
    $(tr).appendTo(thead)

    /// Headers
    if (o !== undefined && Object.keys(o).length !== 0) {

        $.each(o.at(0), function (k, v) {
            const th = document.createElement('th')
            $(th).text(k)
                .appendTo(tr)
        });
    }

    const trClasses = ["table-primary", "table-secondary", "table-info", "table-light"]
    var dict = {}
    i = 0


    const tbody = document.createElement('tbody')
    $(tbody).appendTo(table)

    class_test = tests[e]

    // Rows
    $.each(o, function () {
        const tr = document.createElement('tr')


        // Group by PSComputerName
        dict[this['PSComputerName']] = dict[this['PSComputerName']] === undefined ? trClasses[i++ % trClasses.length] : dict[this['PSComputerName']]
        $(tr).addClass(dict[this['PSComputerName']])
            .appendTo(tbody)

        $.each(this, function (k, v) {
            const td = document.createElement('td')
            const _td = $(td).text(v)
            if (class_test !== undefined && class_test[k] !== undefined) {
                if (class_test[k] === "isPassDate") {
                    const date = v.split('/')
                    if (date.length === 3) {
                        const exp = new Date(date[2], date[0] - 1, date[1]);
                        const now = new Date();
                        (now > exp) ? _td.addClass('table-danger') : _td.addClass('table-success')
                    }
                } else if (class_test[k] === "isLessThan65536") {
                    (65536 > v) ? _td.addClass('table-danger') : _td.addClass('table-success')
                } else if (class_test[k] === "isLessThan1000") {
                    (1000 > v) ? _td.addClass('table-danger') : _td.addClass('table-success')
                } else {
                    (class_test[k] != String(v)) ? _td.addClass('table-danger') : _td.addClass('table-success')
                }
            }
            _td.appendTo(tr)
        });
    });
}


