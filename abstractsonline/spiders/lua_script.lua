treat = require("treat")

function main(splash, args)
    local set_max_per_page = splash:jsfunc([[
        function() {
            document.querySelector(".results-per-page button:last-child").click()
        }
    ]])

    local expand_items_js = [[
        function main(splash) {
            list = document.querySelectorAll("#results li.result i.icon-caret-right");
            for (i=0;i<list.length;i++)
                setTimeout(
                    function(el, is_final){
                        el.click();
                        if (is_final)
                           splash.resume()
                    },
                    i*500, list[i], i==list.length-1
                )
        }
    ]]

    local expand_items = splash:jsfunc(expand_items_js)

    local click_next = splash:jsfunc([[
        function () {
            var next_btn = document.querySelector("#paginator li.next")
            if (next_btn && next_btn.getAttribute('class').indexOf('disabled')===-1) {
                next_btn.querySelector('span').click();
                console.log('Next page')
                return true;
            }
            else
                return false;
        }
    ]])

--    splash.resource_timeout = 600
    splash.images_enabled = false
    assert(splash:go(args.url))
    splash:wait(7)

    set_max_per_page()

    --splash:set_viewport_full()

    local result_arr = {}
    local counter = 0
    repeat
        splash:wait(2)
--        expand_items()
        splash:wait_for_resume(expand_items_js, 60)
        splash:wait(2)
        table.insert(result_arr, splash:html())
        counter=counter+1
    until not click_next() or counter==args.max_pages

    return treat.as_array(result_arr)
end