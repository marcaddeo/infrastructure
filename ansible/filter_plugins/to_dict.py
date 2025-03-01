class FilterModule(object):
  def filters(self):
    return {
      'to_dict': lambda list: dict(list)
    }
