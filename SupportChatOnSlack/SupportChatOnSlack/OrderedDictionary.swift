//
//  ReverseOrderedDictionary.swift
//  SwiftDataStructures
//
//  Created by Tim Ekl on 6/2/14.
//  Created by @dobridog on 9/9/16.
//  Copyright (c) 2014 Tim Ekl. Available under MIT License. See LICENSE.md.
//

import Foundation

struct OrderedDictionary<K: Hashable,V> {
    private var keys: Array<K> = []
    private var dict: Dictionary<K,(Int, V)> = [:]
    
    /*
     Computes the index of the last element in the dictionary
    */
    var lastIndex:Int {
        get {
            return keys.count - 1
        }
    }
    
    var count: Int {
        assert(keys.count == dict.count, "Keys and values array out of sync")
        return self.keys.count;
    }
    
    // Explicitly define an empty initializer to prevent the default memberwise initializer from being generated
    init() {}
    
    subscript(index: Int) -> V? {
        get {
            let key = self.keys[index]
            return self.dict[key]?.1
        }
        set(newValue) {
            //TODO safe index
            let key = self.keys[index]
            if (newValue != nil) {
                self.dict[key] = (index, newValue!)
            } else {
                self.dict.removeValue(forKey: key)
                self.keys.remove(at: index)
            }
        }
    }
    
    subscript(key: K) -> V? {
        get {
            return self.dict[key]?.1 ?? nil
        }
        set(newValue) {
            if newValue == nil {
                self.dict.removeValue(forKey: key)
                self.keys = self.keys.filter {$0 != key}
            } else {
                let keyExists = self.dict[key] != nil
                
                if keyExists {
                    self.dict[key]!.1 = newValue!
                } else {
                    self.keys.append(key)
                    self.dict[key] = (lastIndex, newValue!)
                }
            }
        }
    }
    
    /*
     Returns element's index if the element exists, otherwise -1
    */
    func indexFor(key searchKey: K) -> Int {
        return self.dict[searchKey]?.0 ?? -1
    }
    
    var description: String {
        var result = "{\n"
        for i in 0..<self.count {
            result += "[\(i)]: \(self.keys[i]) => \(self[i])\n"
        }
        result += "}"
        return result
    }
}
