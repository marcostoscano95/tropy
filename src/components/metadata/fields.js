'use strict'

const React = require('react')
const { Component, PropTypes } = React
const { Field } = require('./field')
const { get } = require('../../common/util')


class Fields extends Component {

  isEditing(uri) {
    return get(this.props,
      ['ui', 'edit', 'field', this.props.subject.id]) === uri
  }

  isExtra(uri) {
    const { template } = this.props

    if (uri === 'id') return false
    if (!template) return true

    return !template.fields.find(({ property }) => property.uri === uri)
  }

  *extras() {
    for (let uri in this.props.subject.data) {
      if (this.isExtra(uri)) yield uri
    }
  }

  renderTemplateFields() {
    const { template, subject, ...props } = this.props

    if (!template) return

    return template.fields.map(({ property }) =>
      <Field {...props}
        key={property.uri}
        data={subject.data}
        property={property}
        isEditing={this.isEditing(property.uri)}/>
    )
  }

  renderExtraFields() {
    const { subject, properties, ...props } = this.props

    return [...this.extras()].map(uri =>
      <Field {...props}
        key={uri}
        data={subject.data}
        property={properties[uri] || { uri }}
        isExtra
        isEditing={this.isEditing(uri)}/>
    )
  }

  render() {
    return (
      <ol className="metadata-fields">
        {this.renderTemplateFields()}
        {this.renderExtraFields()}
      </ol>
    )
  }

  static propTypes = {
    ui: PropTypes.object,
    isDisabled: PropTypes.bool,

    template: PropTypes.shape({
      fields: PropTypes.arrayOf(PropTypes.shape({
        property: PropTypes.object.isRequired
      })).isRequired,
    }),

    properties: PropTypes.object,
    static: PropTypes.string,

    subject: PropTypes.shape({
      id: PropTypes.number.isRequired,
      data: PropTypes.object.isRequired,
    }).isRequired,

    onEdit: PropTypes.func,
    onEditCancel: PropTypes.func,
    onMetadataSave: PropTypes.func,
    onContextMenu: PropTypes.func
  }
}


module.exports = {
  Fields
}
