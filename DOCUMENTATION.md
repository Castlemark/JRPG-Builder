# DOCUMENTATION

>   As of now this documentation shouldn't be taken seriously, what you'll read here are notes taken by the dev team  to remember certain things.

Journal can be triggered by combat, reach map node, buy item, kill amount monsters, ... Most probably will be definied in the campaign file

*   Map files (map.json):

    *   Fields:

        *   ``name: {}`` 

        *   ``navigation_nodes: [{}]``

            *   ``x: float``

            *   ``y: float``

            *   ``connected_nodes[int]``

            *   optional: ``actions:[{}]``

                *   ``type: string``
                *   ``data: {}``
                    *   see acions for more information

                

    *   maps should always contain a ``name `` field and this name field should always have the same name as the map folder it's in. Not having the same name or having no name at all won't bring any problems if the file is valid, but will make debugging harder when users create content (for them and for us).