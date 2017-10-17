'use strict'

const { promises: jsonld } = require('jsonld')

const { camelize, omit } = require('./util')
const { ITEM } = require('../constants/type')
const { TEMPLATE } = require('../constants/ontology')
const { getLabel } = require('./ontology')


function propertyLabel(property, props, template) {
  var label, field
  try {
    if (template) {
      field = template.fields.find(f => f.property === property)
      label = field.label
    }
    if (!label) {
      label = props[property] && props[property].label
    }
    if (!label) {
      label = getLabel(field.id)
    }
    return label
  } catch (_) { return label }
}

function shortenLabel(label) {
  return camelize(
    label
    .toLowerCase()
    .trim()
    .normalize('NFD')                // normalize unicode
    .replace(/[\u0300-\u036f]/g, '') // remove accents, ligatures
    .replace(/[^a-zA-Z0-9]+/g, ' ')  // remove non-alphanumeric
  ).replace('_', ' ')                // remove _
}

function shorten() {
  const label = propertyLabel(...arguments)
  if (label) return shortenLabel(label)
}

function createContext(item_template, metadata, props) {
  var context = {
    template: { '@id': TEMPLATE.TYPE, '@type': '@id' }
  }

  // add fields to context
  for (const field of item_template.fields) {
    const short = shorten(field.property, props, item_template)
    if (short) {
      context[short] = {
        '@id': field.property,
        '@type': field.datatype
      }
    }
  }

  return context
}

function createDocument(item_template, metadata, props) {
  var document = {
    '@type': ITEM,
    'template': item_template.id
  }

  // add metadata to document.metadata
  for (const property in metadata) {
    const short = shorten(property, props, item_template)
    if (short) {
      const text = metadata[property].text
      if (text) {
        document[short] = text
      }
    }
  }

  return document
}

function itemToLD() {
  const document = createDocument(...arguments)
  const context = createContext(...arguments)

  document['@context'] = context
  return jsonld.compact(document, context)
}

//////// Grouped
async function groupedByTemplate(resources, props) {
  function makeContext(template) {
    const result = {
      '@vocab': 'https://tropy.org/v1/tropy#',
      'template': TEMPLATE.TYPE,
      'items': {
        '@id': ITEM,
        '@container': '@list',
        '@context': {}
      }
    }
    // TODO fill context up with metadata items
    // TODO don't include fields that have no metadata set

    // fill context up with template items
    for (const field of template.fields) {
      const short = shorten(field.property, props, template)
      if (short) {
        result['items']['@context'][short] = {
          '@id': field.property,
          '@type': field.datatype
        }
      }
    }

    return result
  }

  function makeDocument(items, metadata, template) {
    const result = {
      template: template.id,
      items: []
    }
    for (const i in items) {
      const item = items[i]
      let doc = {}
      // fill items up with metadata
      for (const property in metadata[item.id]) {
        const short = shorten(property, props, template)
        if (short) {
          const text = metadata[item.id][property].text
          if (text) {
            doc[short] = text
          }
        }
      }
      result.items.push(doc)
    }
    return result
  }

  const results = []
  for (const r in resources) {
    const { items, template, metadata } = resources[r]
    const context = makeContext(template)
    const document = makeDocument(items, metadata, template)
    document['@context'] = context
    results.push(await jsonld.compact(document, context))
  }
  return results
}

//////// Import

class ParseError extends Error {
  constructor(obj, ...args) {
    super(...args)
    Error.captureStackTrace(this, ParseError)

    this.details = JSON.stringify(obj, null, 2)
  }
}

async function itemFromLD(obj) {
  let metadata, type, templateID
  try {
    const [expanded] = await jsonld.expand(obj)
    type = expanded['@type'][0]
    templateID = expanded[TEMPLATE.TYPE][0]['@id']
    metadata = omit(expanded, ['@type', TEMPLATE.TYPE])
  } catch (e) {
    throw new ParseError(obj, 'Could not parse jsonld object')
  }

  // convert metadata to a format supported by `mod.item.create`
  let md = {}
  for (let property in metadata) {
    const [prop] = metadata[property]
    md[property] =  {
      type: prop['@type'],
      text: prop['@value']
    }
  }

  return { type, templateID, metadata: md }
}

module.exports = {
  shortenLabel,
  propertyLabel,
  itemToLD,
  itemFromLD,
  ParseError,
  groupedByTemplate
}
