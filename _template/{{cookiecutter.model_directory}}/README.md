{%- extends "vars.jinja" -%}
{%- block content -%}
# {{ cookiecutter.title }}{% if remix %} (remix){% endif %}

[![{{ cookiecutter.original_model_license }} license][license-badge]][license]

{{ cookiecutter.description }}

![Model render](images/readme/demo.png)
{% if remix %}
## Attribution and License

This is a remix of
[**{{ cookiecutter.original_model_title|default("this model") }}** by **{{ cookiecutter.original_model_author }}**][original-model-url].

Both the original model and this remix are licensed under
[{{ license_title }}][license].
{% else %}
## License

This model is licensed under [{{ license_title}}][license].
{% endif %}
{% if remix -%}
[original-model-url]: {{ cookiecutter.original_model_url }}
{%- endif %}
[license]: {{ license_url }}
[license-badge]: /_static/license-badge-{{ cookiecutter.original_model_license.lower() }}.svg
{% endblock -%}
