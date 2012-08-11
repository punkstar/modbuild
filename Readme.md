# Magento Package XML Builder for Modman

[![Build Status](https://secure.travis-ci.org/punkstar/modbuild.png?branch=master)](http://travis-ci.org/punkstar/modbuild)

I use [modman](https://github.com/colinmollenhour/modman) to manage any Magento Extensions that I write.  An extension must be packaged once it's complete.  I don't enjoy using the "Package Magento Extension" interface in the Magento admin, nor do I like writing the XML by hand.

This script gives you a running start by generating an XML file that you can then load in the admin interface containing most of the information you'll need, such as all of the files included in the extension and any metadata that you've included in your modman file.

### Example modman File

You can include basic information, such as extension name, version, summary and description, in your modman file to be included in the generated XML file.  For example:

    # Name: Meanbee_Topsecret
    # Version: 1.0.0
    # Description: This is a topsecret module, and no-one must know about it.
    # Summary: I'm not telling.
    
    app/etc/modules/Meanbee_Topsecret.xml app/etc/modules/

### Example Usage

If I had a Magento installation in `~/Sites/meanbee/module_topsecret/`, and a modman compatible repoistory checked out in `~/Sites/meanbee/module_topsecreet/.modman/topsecret`, then I would run the following to generate an almost complete package file in `var/connect`:

    modbuild ~/Sites/meanbee/module_topsecreet/.modman/topsecret > ~/Sites/meanbee/module_topsecret/var/connect/Meanbee_Topsecret.xml

### License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
