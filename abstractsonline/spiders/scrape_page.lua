treat = require("treat")

function main(splash, args)


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
    --splash:set_viewport_full()

    assert(splash:set_content(args.html))
    splash:wait_for_resume(expand_items_js, 60)
    splash:wait(2)
    click_next()
    return splash:html()
end