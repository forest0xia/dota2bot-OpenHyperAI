const ts = require('typescript');

function customTransformer() {
    console.log("Custom transformer is running...");

    return (context) => {
        const visit = (node) => {
            // Check if the node is a call expression and has at least one argument
            if (ts.isCallExpression(node) && node.arguments.length > 0) {
                const argument = node.arguments[0];
                if (ts.isStringLiteral(argument)) {
                    console.log("Found CallExpression with StringLiteral argument:", argument.text);

                    // Check if the string literal starts with "bots."
                    if (argument.text.startsWith('bots/')) {
                        const newPath = `GetScriptDirectory().."/${argument.text.slice(5).replace(/\./g, '/')}"`;
                        console.log(`Transforming require path: '${argument.text}' to '${newPath}'`);

                        // Create a new string literal with the transformed path
                        const newStringLiteral = ts.factory.createStringLiteral(newPath);
                        const updatedNode = ts.factory.updateCallExpression(
                            node,
                            node.expression,
                            node.typeArguments,
                            [newStringLiteral]
                        );

                        // Return the updated node to apply the transformation
                        return updatedNode;
                    }
                }
            }

            // Visit other children nodes
            return ts.visitEachChild(node, visit, context);
        };

        return (node) => ts.visitNode(node, visit);
    };
}

module.exports = customTransformer;
