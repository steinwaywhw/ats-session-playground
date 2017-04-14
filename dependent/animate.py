from dot_tools import *
from dot_tools.dot_graph import *
from subprocess import call

class AnimatedGraph(SimpleGraph):

    def __init__(self, tree, step):
        SimpleGraph.__init__(self)
        self._walk(tree.kid('Graph'))
        self.step = step

    def dotty(self, name, no_header_footer=False, html=False):
        def string(label):
            if html:
                label = (
                    label.replace("'", "\\'").
                    replace('"', '\\"').
                    replace('\n', '\\n')
                )
                label = cgi.escape(label).encode('ascii', 'xmlcharrefreplace')
                s = ''.join(
                    '<tr><td align="left">' + line + "</td></tr>"
                    for line in label.split('\\n')
                )
            else:
                s = (
                    label.replace('"', '').
                    replace('"', '').
                    replace('\\', '').
                    replace('\n', '')
                )
            return s

        header = 'digraph %s {' % name
        footer = '}'
        if html:
            node = '"%s" [shape=rect, fontname="Courier", label=<<table border="0">%s</table>>];'
        else:
            node = '"%s" [label="%s"];'
        edge = '"%s"->"%s" [label="%s"];'

        current_edge = '"%s"->"%s" [label="%s",color="red",fontcolor="red",penwidth=2];'

        nodes = list()
        edges = list()

        keys = sorted(self.nodes.keys())
        for nid in keys:
            nodes.append(node % (self.dotty_nid(nid), string(self.nodes[nid].get('label', nid))))

        for s, t, label in self.edges:
            if label.startswith("%d:" % (self.step)):
                edges.append(current_edge % (self.dotty_nid(s), self.dotty_nid(t), label))
            else:
                edges.append(edge % (self.dotty_nid(s), self.dotty_nid(t), label))

        if no_header_footer:
            return (
                '\n'.join(nodes) + '\n' +
                '\n'.join(edges) + '\n'
            )
        return (
            header + '\n' +
            '\n'.join(nodes) + '\n' +
            '\n'.join(edges) + '\n' +
            footer + '\n'
        )

def main():
    file = open("error.log")
    content = "digraph{\n" + file.read() + "\n}"
    file.close()

    tree = parse(content)
    graph = AnimatedGraph(tree, 1)

    for i in range(1,len(graph.edges)+1):
        graph = AnimatedGraph(tree, i)

        file = open("./animate/step%d.gv" % i, "w")
        file.write(graph.dotty("test"))
        file.close()

        call(["dot", "-Tpng", "-O", "animate/step%d.gv" % i])
        call(["rm", "animate/step%d.gv" % i])


if __name__ == '__main__':
    main()
