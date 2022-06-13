// Validator utils module

/**
 * @typedef ObjectProps
 * @type {Object.<string, Schema>}
 *
 * @typedef OneOfItems
 * @type {Array.<Schema>}
 */
class Schema {
  constructor({ title, id, additionalProperties, required }) {
    this.rule = {};
    if (title) {
      this.rule.title = title;
    }
    if (id) {
      this.rule.ID = id;
    }
    this.rule.additionalProperties = additionalProperties;
    if (required) {
      this.required = required;
    }
  }

  /**
   * Returns new Schema with title, id and additionalProperties joined to rule
   * @param {string} title
   * @param {string} [id=/root]
   * @param {boolean} [additionalProperties=false]
   * @returns {Schema}
   */
  static root(title, id = "/root", additionalProperties = false) {
    return new Schema({ title, id, additionalProperties });
  }

  /**
   * Returns clear new Schema
   * @returns {Schema}
   */
  static create() {
    return new Schema({});
  }

  /**
   * Returns new Schema with required property as false
   * @returns {Schema}
   */
  static optional() {
    return new Schema({ required: false });
  }

  /**
   * Returns new Schema with required property as true
   * @returns {Schema}
   */
  static required() {
    return new Schema({ required: true });
  }

  /**
   * Assigns object to schema destructuring type from it and assigns it with .assignType method
   * @access private
   * @param {Object} rule
   * @returns {Schema}
   */
  assign(rule) {
    const { type, ...rules } = rule;
    if (type) {
      this.assignType(type);
    }
    Object.assign(this.rule, rules);
    return this;
  }

  /**
   * Assigns string type to schema. If type is not set assigns type as array of provided string otherwise pushes new string to type property
   * @access private
   * @param {string} type
   */
  assignType(type) {
    if (!this.rule.type) {
      this.rule.type = [type];
    } else {
      this.rule.type.push(type);
    }
  }

  /**
   * Assigns string type to schema
   * minItems and maxItems properties are assigned when value !== null
   * @access public
   * @param {number|null} [minLength=null]
   * @param {number|null} [maxLength=null]
   * @returns {Schema}
   */
  string(minLength = null, maxLength = null) {
    const rule = { type: "string" };

    if (minLength !== null) {
      rule.minLength = minLength;
    }
    if (maxLength !== null) {
      rule.maxLength = maxLength;
    }
    return this.assign(rule);
  }

  /**
   * Assigns number type to schema
   * minimum and maximum properties are assigned when value !== null
   * @access public
   * @param {number|null} [minimum=null]
   * @param {number|null} [maximum=null]
   * @returns {Schema}
   */
  number(minimum = null, maximum = null) {
    const rule = { type: "number" };
    if (minimum !== null) {
      rule.minimum = minimum;
    }
    if (maximum !== null) {
      rule.maximum = maximum;
    }
    return this.assign(rule);
  }

  /**
   * Assigns number type to schema
   * minimum and maximum properties are assigned when value !== null
   * @access public
   * @param {date-time} type
   * @returns {Schema}
   */
  date() {
    const rule = {
      type: "string",
    };
    return this.assign(rule);
  }

  /**
   * Assigns null type to schema
   * @access public
   * @returns {Schema}
   */
  nullable() {
    return this.assign({ type: "null" });
  }

  /**
   * Assigns enum property to schema as following { enum: keywords }
   * @access public
   * @param {Array} keywords
   * @returns {Schema}
   */
  enum(keywords) {
    return this.assign({ enum: keywords });
  }

  /**
   * Assigns const property to schema as following { const: constant }
   * @access public
   * @param {string} constant
   * @returns {Schema}
   */
  equals(constant) {
    return this.assign({ const: constant });
  }

  /**
   * Assigns custom object to schema as following { ...rule }
   * @access public
   * @param {Object} rule
   * @returns {Schema}
   */
  setRule(rule) {
    return this.assign(rule);
  }

  /**
   * Assigns reference rule to schema as following { $ref: id }
   * @access public
   * @param {string} id
   * @returns {Schema}
   */
  ref(id) {
    return this.assign({ $ref: id });
  }

  /**
   * Assigns object rule to schema as following { type: 'object', properties: {props.key}, required: [...props.key] }
   * properties is joined when each props Schema.build() result is not empty
   * required is joined when Schema.required=true of provided props values
   * @access public
   * @param {ObjectProps} props
   * @returns {Schema}
   */
  object(props) {
    const rule = { type: "object" };
    const properties = {};
    const required = [];

    Object.entries(props).forEach(([name, prop]) => {
      if (prop.required) {
        required.push(name);
      }
      const property = prop.build();
      if (Object.keys(property).length) {
        properties[name] = property;
      }
    });
    if (Object.keys(properties).length > 0) {
      rule.properties = properties;
    }
    if (required.length > 0) {
      rule.required = required;
    }

    return this.assign(rule);
  }

  /**
   * Returns array rule as following { type: 'array', items: items },
   * minItems and maxItems properties are joined to assigned object when value !== null
   * @access private
   * @param {Object} items
   * @param {number|null} [minItems=null]
   * @param {number|null} [maxItems=null]
   * @returns
   */
  createArray(items, minItems = null, maxItems = null) {
    const rule = { type: "array", items };
    if (minItems !== null) {
      rule.minItems = minItems;
    }
    if (maxItems !== null) {
      rule.maxItems = maxItems;
    }
    return rule;
  }

  /**
   * Assigns array rule to schema as following { type: 'array', items: schema }
   * minItems and maxItems properties are joined to assigned object when value !== null
   * @access public
   * @param {Schema} schema
   * @param {number} [minItems=null]
   * @param {number} [maxItems=null]
   * @returns {Schema}
   */
  array(schema, minItems = null, maxItems = null) {
    const rule = this.createArray(schema.build(), minItems, maxItems);
    return this.assign(rule);
  }

  /**
   * Assigns array rule to schema from builded object schema as following { type: 'array', items: { type: 'object', properties: props } }
   * minItems and maxItems properties are joined to assigned object when value !== null
   * @access public
   * @param {ObjectProps} props
   * @param {number} [minItems=null]
   * @param {number} [maxItems=null]
   * @returns {Schema}
   */
  arrayOfObjects(props, minItems = null, maxItems = null) {
    const objectSchema = Schema.create().object(props);
    return this.array(objectSchema, minItems, maxItems);
  }

  /**
   * Returns new array of Schema.build() result on each element in provided array
   * @access private
   * @param {OneOfItems} items
   * @returns {Schema}
   */
  createOneOf(items) {
    return items.map((item) => item.build());
  }

  /**
   * Assigns oneOf array rule to schema as following { type: 'array', items: { oneOf: items } }.
   * Items are instanceof Schema so on every item in array triggers .build() method
   * minItems and maxItems properties are joined to assigned object when value !== null
   * @access public
   * @param {OneOfItems} items
   * @param {number} [minItems=null]
   * @param {number} [maxItems=null]
   * @returns {Schema}
   */
  arrayOfAny(items, minItems = null, maxItems = null) {
    const oneOf = this.createOneOf(items);
    const rule = this.createArray({ oneOf }, minItems, maxItems);
    return this.assign(rule);
  }

  /**
   * Assigns oneOf object rule to schema as following { type: 'object', properties: { oneOf: items } }.
   * Items are instanceof Schema so on every item in array triggers .build() method
   * @access public
   * @param {OneOfItems} items
   * @returns {Schema}
   */
  objectOfAny(items) {
    const oneOf = this.createOneOf(items);
    return this.assign({ type: "object", properties: { oneOf } });
  }

  /**
   * Returns created rule object of this instance
   * @access public
   * @returns {Object}
   */
  build() {
    return this.rule;
  }
}

class Rules {
  static enum(keywords) {
    return Schema.optional().enum(keywords);
  }

  static requiredEnum(keywords) {
    return Schema.required().enum(keywords);
  }

  static stringNotEmpty(maxLength = null) {
    return Schema.optional().string(1, maxLength);
  }

  static requiredStringNotEmpty(maxLength = null) {
    return Schema.required().string(1, maxLength);
  }

  static nullOrString(maxLength = null) {
    return Schema.optional().nullable().string(null, maxLength);
  }

  static requiredEquals(constant) {
    return Schema.required().equals(constant);
  }
  static requiredDate() {
    return Schema.required().date();
  }
}

module.exports = {
  Schema,
  Rules,
};
